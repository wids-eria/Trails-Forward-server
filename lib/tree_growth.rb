module TreeGrowth
  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods
  end

  TREE_UPGROWTH_P = {
    shade_tolerant:    [ 0.016405, -0.000128,    0.005542, -0.000206, 0.0        ],
    mid_tolerant:      [ 0.01341,  -0.000175,    0.005121, -0.000244, 0.00002439 ],
    shade_intolerant:  [ 0.006936, -0.000097202, 0.0059,   -0.000188, 0.0        ]
  }

  # Col 2 is michigan variant.
  TREE_MORTALITY_P = {
    shade_tolerant:   [ 0.033573, 0, -0.00175,  0.00013,  -0.000016915 ],
    mid_tolerant:     [ 0.041762, 0, -0.003304, 0.000111, 0.0          ],
    shade_intolerant: [ 0.041841, 0, -0.000916, 0.0     , 0.0          ]
  }

  TREE_INGROWTH_PARAMETER = {
    shade_tolerant:   [ 18.186617, -0.096585 ],
    mid_tolerant:     [ 4.603454,  -0.035261 ],
    shade_intolerant: [ 7.621893,  -0.058816 ]
  }


  def grow_trees
    return if species_group.blank?

    tree_size_counts = collect_tree_size_counts 

    tree_size_count_matrix = Matrix[tree_size_counts]
    transition_matrix = Matrix.identity tree_sizes.length

    basal_area = calculate_basal_area(tree_sizes, tree_size_count_matrix.flat_map.to_a)

    tree_sizes.each_with_index do |tree_size, index|
      mortality_rate = determine_mortality_rate(tree_size, species_group, site_index)
      upgrowth_rate  = determine_upgrowth_rate(tree_size, species_group, site_index, basal_area)

      mortality_rate = [0, mortality_rate].max
      upgrowth_rate  = [0, upgrowth_rate].max

      transition_matrix.send "[]=", index,index, (1 - upgrowth_rate - mortality_rate)

      # derive sub diagonal from each element in the diagonal except last element
      if index < (tree_sizes.count - 1)
        transition_matrix.send "[]=", index, index+1, upgrowth_rate
      end
    end

    # apply matrix
    tree_size_count_matrix = tree_size_count_matrix * transition_matrix

    # add sapling
    ingrowth_count = tree_size_count_matrix.flat_map.to_a[0] + [0, determine_ingrowth_number(species_group, basal_area)].max
    tree_size_count_matrix.send "[]=", 0,0, ingrowth_count

    # set values on model
    tree_sizes.each_with_index do |tree_size, index|
      set_trees_in_size tree_size, tree_size_count_matrix[0,index]
    end
  end



  # Describes the yearly proportion of trees in a diameter class that die
  def determine_mortality_rate(diameter, species, site_index)
    # debugger if diameter = 8 && species == :shade_tolerant
    TREE_MORTALITY_P[species][0] +
      (TREE_MORTALITY_P[species][2] * diameter) +
      (TREE_MORTALITY_P[species][3] * (diameter**2)) +
      (TREE_MORTALITY_P[species][4] * site_index * diameter)
  end

  # Describes the yearly proportion of trees moving from one diameter class to the next
  def determine_upgrowth_rate diameter, species, site_index, basal_area
    return 0.0 if diameter == 24

    TREE_UPGROWTH_P[species][0] +
      TREE_UPGROWTH_P[species][1] * basal_area +
      TREE_UPGROWTH_P[species][2] * (diameter) +
      TREE_UPGROWTH_P[species][3] * (diameter) ** 2 +
      TREE_UPGROWTH_P[species][4] * site_index * (diameter)
  end

  def determine_ingrowth_number(species_group, basal_area)
    TREE_INGROWTH_PARAMETER[species_group][0] + TREE_INGROWTH_PARAMETER[species_group][1] * basal_area
  end

end
