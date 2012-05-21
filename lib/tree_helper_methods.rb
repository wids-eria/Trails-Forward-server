module TreeHelperMethods
  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods
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

end
