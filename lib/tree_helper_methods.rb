module TreeHelperMethods
  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods
  end

  def site_index
    80.0
  end

  def calculate_basal_area(tree_sizes, tree_size_counts)
    basal_area = 0
    tree_sizes.each_with_index do |tree_size, index|
      basal_area += basal_area_for_size(tree_size) * tree_size_counts[index]
    end
    basal_area
  end

  def basal_area_for_size(tree_size)
    (tree_size) ** 2 * 0.005454154
  end
  def tree_sizes
    [2,4,6,8,10,12,14,16,18,20,22,24]
  end

  def collect_tree_size_counts
    tree_sizes.collect {|diameter| trees_in_size diameter }
  end

  def trees_in_size(tree_size)
    self.send "num_#{tree_size}_inch_diameter_trees"
  end

  def set_trees_in_size(tree_size, value)
    self.send "num_#{tree_size}_inch_diameter_trees=", value
  end


  def shade_intolerant?; species_group == :shade_intolerant; end
  def shade_tolerant?; species_group == :shade_tolerant; end
  def mid_tolerant?; species_group == :mid_tolerant; end


  def poletimber_sizes
    if shade_tolerant? || mid_tolerant?
      [6,8,10]
    elsif shade_intolerant?
      [6,8]
    end
  end

  def sawtimber_sizes
    if shade_tolerant? || mid_tolerant?
      [12,14,16,18,20,22,24]
    elsif shade_intolerant?
      [10,12,14,16,18,20,22,24]
    end
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
end
