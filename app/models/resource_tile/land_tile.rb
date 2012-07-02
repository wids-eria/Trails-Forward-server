class LandTile < ResourceTile
  include TreeHelperMethods
  include TreeGrowth
  include TreeValue
  include TreeHarvesting

  before_save :memoize_basal_area
  before_save :calculate_marten_suitability  #kevin wants to move this to an observer later, and that's aok with me

  def can_clearcut?
    begin
      species_group
    rescue
      return false
    end

    true
  end

  def clearcut!
    results = clearcut
    save!
    return results
  end

  def diameter_limit_cut! options
    results = diameter_limit_cut options
    save!
    return results
  end

  def partial_selection_cut! options
    results = partial_selection_cut options
    save!
    return results
  end

  def tick
  end

  def can_bulldoze?
    true
  end

  def bulldoze!
    if can_bulldoze?
      World.transaction do
        clear_resources
        save!
      end
    else
      raise "This land cannot be bulldozed"
    end
  end

  def estimated_timber_value
    if shade_tolerant? || shade_intolerant? || mid_tolerant?
      estimated_poletimber_value + estimated_sawtimber_value
    else
      0
    end
  end


  def estimated_poletimber_value
    poletimber_sizes.collect{|size| self.send "estimated_#{size}_inch_tree_value"}.sum
  end

  def estimated_poletimber_volume
    poletimber_sizes.collect{|size| self.send "estimated_#{size}_inch_tree_volume"}.sum
  end

  def estimated_sawtimber_value
    sawtimber_sizes.collect{|size| self.send "estimated_#{size}_inch_tree_value"}.sum
  end

  def estimated_sawtimber_volume
    sawtimber_sizes.collect{|size| self.send "estimated_#{size}_inch_tree_volume"}.sum
  end

  def estimated_tree_volume_for_size(size, tree_count)
    basal_area = calculate_basal_area tree_sizes, collect_tree_size_counts
    merchantable_height = merchantable_height(size, basal_area, site_index)
    single_tree_volume  = single_tree_volume(size, merchantable_height)
    single_tree_volume * tree_count
  end

  def estimated_tree_value_for_size(size, tree_count)
    if (2..4).include? size
      return 0
    end

    volume = estimated_tree_volume_for_size size, tree_count

    if poletimber_sizes.include?(size)
      cubic_feet_to_cords(volume) * cord_value
    elsif sawtimber_sizes.include?(size)
      cubic_feet_to_board_feet(volume, size) * board_feet_value
    end
  end

  [2,4,6,8,10,12,14,16,18,20,22,24].each do |tree_size|
    define_method "estimated_#{tree_size}_inch_tree_value" do
      estimated_tree_value_for_size tree_size, self.send("num_#{tree_size}_inch_diameter_trees")
    end
  end

  def cord_value
    case species_group
    when :shade_intolerant
      14.00
    when :shade_tolerant
      12.00
    when :mid_tolerant
      13.00
    end
  end

  def board_feet_value
    case species_group
    when :shade_intolerant
      0.147
    when :shade_tolerant
      0.151
    when :mid_tolerant
      0.127
    end
  end

  def single_tree_volume(size_class, merchantable_height)
    case species_group
    when :shade_tolerant
      2.706 + 0.002 * (size_class-1)**2 * merchantable_height
    when :mid_tolerant
              0.002 * (size_class-1)**2 * merchantable_height
    when :shade_intolerant
      1.375 + 0.002 * (size_class-1)**2 * merchantable_height
    end
  end

  def merchantable_height(size_class, basal_area, site_index)
    breast_height = 4.5
    case species_group
    when :shade_tolerant
      breast_height + 5.34 * (1 - Math.exp(-0.23 * (size_class-1)))**1.15 * site_index**0.54 * (1.00001 - (top_diameter(size_class)/(size_class-1)))**0.83 * basal_area**0.06
    when :mid_tolerant
      breast_height + 7.19 * (1 - Math.exp(-0.28 * (size_class-1)))**1.44 * site_index**0.39 * (1.00001 - (top_diameter(size_class)/(size_class-1)))**0.83 * basal_area**0.11
    when :shade_intolerant
      breast_height + 6.43 * (1 - Math.exp(-0.24 * (size_class-1)))**1.34 * site_index**0.47 * (1.00001 - (top_diameter(size_class)/(size_class-1)))**0.73 * basal_area**0.08
    end
  end

  def top_diameter(size_class)
    case species_group
    when :shade_intolerant
      case size_class
        when 0..4
          raise 'no'
        when 6..8
          4
        else
          9
      end
    when :shade_tolerant, :mid_tolerant
      case size_class
        when 0..4
          raise 'no'
        when 6..10
          4
        else
          9
      end
    end
  end

  def cubic_feet_to_cords(volume)
    volume / 128.0
  end


  SCRIBNER_FACTOR = {
    :shade_tolerant =>                { 12 => 0.832, 14 => 0.861, 16 => 0.883, 18 => 0.900, 20 => 0.913, 22 => 0.924, 24 => 0.933 },
    :mid_tolerant =>                  { 12 => 0.832, 14 => 0.861, 16 => 0.883, 18 => 0.900, 20 => 0.913, 22 => 0.924, 24 => 0.933 },
    :shade_intolerant => { 10 => 0.783, 12 => 0.829, 14 => 0.858, 16 => 0.878, 18 => 0.895, 20 => 0.908, 22 => 0.917, 24 => 0.924 }

  }
  def cubic_feet_to_board_feet(volume, size_class)
    volume * 12 * SCRIBNER_FACTOR[species_group][size_class]
  end

  def tree_sizes
    [2,4,6,8,10,12,14,16,18,20,22,24]
  end

  def collect_tree_size_counts
    tree_sizes.collect {|diameter| trees_in_size diameter }
  end

  def site_index
    80
  end

  def grow_trees! years = 1
    years.times { grow_trees }
    self.save!
  end

  # TODO dont save
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
      TREE_MORTALITY_P[species][2] * (diameter-1) +
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

  def species_group
    case self.landcover_class_code
    when 41
      :shade_tolerant
    when 42, 90
      :mid_tolerant
    when 43
      :shade_intolerant
    else
      raise 'No Trees'
    end
  end

  def calculate_marten_suitability!(force = false)
    calculate_marten_suitability force
    save!
  end

  def calculate_marten_suitability(force = false)
    if force or trees_have_changed? or (self.small_tree_basal_area == nil) or (self.large_tree_basal_area == nil)
      memoize_basal_area force
    end
    
    return if (self.small_tree_basal_area == nil) or (self.large_tree_basal_area == nil)
    
    if MARTEN_SUITABLE_CLASS_CODES.include? self.landcover_class_code
      if small_tree_basal_area < large_tree_basal_area
        self.marten_suitability = 1
      else
        self.marten_suitability = 0
      end
    else self.marten_suitability = 0
    end
    #puts "Marten Suitability = #{marten_suitability}"
  end

  def memoize_basal_area(force = false)
    if trees_have_changed? or force
      size_array = self.collect_tree_size_counts
      self.small_tree_basal_area = calculate_basal_area(tree_sizes[0,5], size_array[0,5])
      self.large_tree_basal_area = calculate_basal_area(tree_sizes[6,12], size_array[6,12])
    end
  end

  def trees_have_changed?
    tree_fields= [:num_2_inch_diameter_trees, :num_4_inch_diameter_trees,
      :num_6_inch_diameter_trees, :num_8_inch_diameter_trees,
      :num_10_inch_diameter_trees, :num_12_inch_diameter_trees,
      :num_14_inch_diameter_trees, :num_16_inch_diameter_trees, 
      :num_18_inch_diameter_trees, :num_20_inch_diameter_trees,
      :num_22_inch_diameter_trees, :num_24_inch_diameter_trees].map do |foo| foo.to_s end
    changed_trees = self.changed_attributes.keys & tree_fields
    ret = changed_trees.length > 0
    ret
  end


  def estimated_value
    # MatLab equation:
    # lntotalprice=bdum.*coeff(1,1)+lntotalacres.*coeff(1,2)+lntot2.*coeff(1,3)+lnfrontage.*coeff(1,4)+lnf2.*coeff(1,5)+lnlakesize.*coeff(1,6);
    # lntotalprice=lntotalprice+lnlake2.*coeff(1,7)+sone.*coeff(1,8)+stwo.*coeff(1,9)+szero.*coeff(1,10)+10.24;
    # totalprice=exp(lntotalprice);

    coeff=[1.113921,0.2421629,0.0017476,0.0879644,0.0144558,0.249173,0.0058711,-0.046306,0.0342448,0.0038761,10.24675];

    bdum = 0.0
    if self.housing_density != nil && self.housing_density != 0
      bdum = 1.0
    end

    lntotalacres = 1.0
    lntot2 = lntotalacres ** 2

    lnfrontage = 0.0
    if self.frontage != nil
      lnfrontage = self.frontage
    end
    lnf2 = lnfrontage ** 2

    lnlakesize = 0.0
    if self.lakesize != nil
      lnlakesize = self.lakesize
    end
    lnlake2 = lnlakesize ** 2

    sone = stwo = szero = 0.0
    case self.soil
    when 0
      szero = 1.0
    when 1
      sone = 1.0
    when 2
      stwo = 1.0
    end

    lntotalprice = bdum*coeff[0]+lntotalacres*coeff[1]+lntot2*coeff[2]+lnfrontage*coeff[3]+lnf2*coeff[4]+lnlakesize*coeff[5]+lnlake2*coeff[6]+sone*coeff[7]+stwo*coeff[8]+szero*coeff[9]+10.24;
    totalprice = Math.exp(lntotalprice)
    totalprice
  end

  def tree_count
    count = 0
    count += self.num_2_inch_diameter_trees  || 0
    count += self.num_4_inch_diameter_trees  || 0
    count += self.num_4_inch_diameter_trees  || 0
    count += self.num_8_inch_diameter_trees  || 0
    count += self.num_10_inch_diameter_trees || 0
    count += self.num_12_inch_diameter_trees || 0
    count += self.num_14_inch_diameter_trees || 0
    count += self.num_16_inch_diameter_trees || 0
    count += self.num_18_inch_diameter_trees || 0
    count += self.num_20_inch_diameter_trees || 0
    count += self.num_22_inch_diameter_trees || 0
    count += self.num_24_inch_diameter_trees || 0
    count
  end

  api_accessible :resource, :extend => :resource_base do |template|
    template.add :primary_use
    template.add :zoning_code
    template.add :people_density
    template.add :housing_density
    template.add :tree_density
    template.add :land_cover_type
    template.add :tree_size
    template.add :development_intensity
    template.add :imperviousness
    template.add :num_2_inch_diameter_trees
    template.add :num_4_inch_diameter_trees
    template.add :num_6_inch_diameter_trees
    template.add :num_8_inch_diameter_trees
    template.add :num_10_inch_diameter_trees
    template.add :num_12_inch_diameter_trees
    template.add :num_14_inch_diameter_trees
    template.add :num_16_inch_diameter_trees
    template.add :num_18_inch_diameter_trees
    template.add :num_20_inch_diameter_trees
    template.add :num_22_inch_diameter_trees
    template.add :num_24_inch_diameter_trees
    template.add :housing_capacity
    template.add :housing_occupants
    template.add :harvest_area
    template.add :supported_saplings
    template.add :tree_type
    template.add :outpost
  end
end
