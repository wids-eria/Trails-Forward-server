module TreeValue
  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods
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
end
