module TreeGrowth
  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods
  end

  TREE_UPGROWTH_P = {
    shade_tolerant:    [0.016405, -0.000128, 0.005542, -0.000206, 0 ],
    mid_tolerant:      [0.0134, -0.0002, 0.0051, -0.0002, 0.00002],
    shade_intolerant:  [0.0069, -0.0001, 0.0059, -0.0003, 0      ]
  }

  # Col 2 is michigan variant.
  TREE_MORTALITY_P = {
    shade_tolerant:   [0.033573, 0, -0.00175, 0.00013, -0.0000169],
    mid_tolerant:     [0.0417, 0, -0.0033, 0.0001,  0      ],
    shade_intolerant: [0.0418, 0, -0.0009, 0     ,  0      ]
  }

  TREE_INGROWTH_PARAMETER = {
    shade_tolerant:   [18.186617, -0.096585],
    mid_tolerant:     [4.603,  -0.035],
    shade_intolerant: [7.622,  -0.059]
  }

  def grow_trees
    return if species_group.blank?

    tree_size_counts = collect_tree_size_counts 

    tree_size_count_matrix = Matrix[tree_size_counts]
    transition_matrix = Matrix.identity tree_sizes.length

    basal_area = calculate_basal_area(tree_sizes, tree_size_count_matrix.flat_map.to_a)

    tree_sizes.each_with_index do |tree_size, index|
      survival_rate = 1 - determine_mortality_rate(tree_size, species_group, site_index)
      upgrowth_rate = determine_upgrowth_rate(tree_size, species_group, site_index, basal_area)
      retention_rate = 1 - upgrowth_rate

      transition_matrix.send "[]=", index,index, survival_rate * retention_rate

      # derive sub diagonal from each element in the diagonal except last element
      if index < (tree_sizes.count - 1)
        #transition_matrix.send "[]=", index+1, index, upgrowth_rate
        transition_matrix.send "[]=", index+1, index, survival_rate * upgrowth_rate
      end
    end

    # apply matrix
    tree_size_count_matrix = tree_size_count_matrix * transition_matrix

    # add sapling
    basal_area = calculate_basal_area(tree_sizes, tree_size_count_matrix.flat_map.to_a)
    tree_size_count_matrix.send "[]=", 0,0, determine_ingrowth_number(species_group, basal_area)

    # set values on model
    tree_sizes.each_with_index do |tree_size, index|
      set_trees_in_size tree_size, tree_size_count_matrix[0,index]
    end

    self.save!
  end

  def calculate_basal_area(tree_sizes, tree_size_counts)
    basal_area = 0
    tree_sizes.each_with_index do |tree_size, index|
      basal_area += basal_area_for_size(tree_size) * tree_size_counts[index]
    end
    basal_area
  end

  def basal_area_for_size(tree_size)
    (tree_size-1) ** 2 * 0.005454154
  end

  # Describes the yearly proportion of trees in a diameter class that die
  def determine_mortality_rate(diameter, species, site_index)
    # debugger if diameter = 8 && species == :shade_tolerant
    TREE_MORTALITY_P[species][0] +
      TREE_MORTALITY_P[species][1] * (diameter-1) +
      # TREE_MORTALITY_P[species][2] * basal_area +
      TREE_MORTALITY_P[species][3] * (diameter-1)**2 +
      TREE_MORTALITY_P[species][4] * site_index * (diameter-1)
  end

  # Describes the yearly proportion of trees moving from one diameter class to the next
  def determine_upgrowth_rate diameter, species, site_index, basal_area
    TREE_UPGROWTH_P[species][0] +
      TREE_UPGROWTH_P[species][1] * basal_area +
      TREE_UPGROWTH_P[species][2] * (diameter-1) +
      TREE_UPGROWTH_P[species][3] * (diameter-1) ** 2 +
      TREE_UPGROWTH_P[species][4] * site_index * (diameter-1)
  end

  def determine_ingrowth_number(species_group, basal_area)
    TREE_INGROWTH_PARAMETER[species_group][0] + TREE_INGROWTH_PARAMETER[species_group][1] * basal_area
  end

end
