module TreeValue
  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods
  end


  # TREE VALUE SUMS ######################
  #

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


  def estimated_sawtimber_value
    sawtimber_sizes.collect{|size| self.send "estimated_#{size}_inch_tree_value"}.sum
  end



  # TREE VOLUME SUMS #####################
  #

  def estimated_poletimber_volume
    poletimber_sizes.collect{|size| self.send "estimated_#{size}_inch_tree_volume"}.sum
  end

  def estimated_sawtimber_volume
    sawtimber_sizes.collect{|size| self.send "estimated_#{size}_inch_tree_volume"}.sum
  end


  [2,4,6,8,10,12,14,16,18,20,22,24].each do |tree_size|
    define_method "estimated_#{tree_size}_inch_tree_value" do
      estimated_tree_value_for_size tree_size, self.send("num_#{tree_size}_inch_diameter_trees")
    end
  end



  # TREE VOLUME ESTIMATION ###############
  #

  def estimated_tree_volume_for_size(size, tree_count)
    basal_area = calculate_basal_area tree_sizes, collect_tree_size_counts
    merchantable_height = merchantable_height(size, basal_area, site_index)
    single_tree_volume  = single_tree_volume(size, merchantable_height)
    single_tree_volume * tree_count
  end



  # TREE VALUE ESTIMATION ################
  #

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



  # BASE UNITS ###########################
  #

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
      world.pine_sawtimber_price
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



  # UNIT CONVERSION ########################
  #
  SCRIBNER_FACTOR = {
    :shade_tolerant   =>              { 12 => 0.832, 14 => 0.861, 16 => 0.883, 18 => 0.900, 20 => 0.913, 22 => 0.924, 24 => 0.933 },
    :mid_tolerant     =>              { 12 => 0.832, 14 => 0.861, 16 => 0.883, 18 => 0.900, 20 => 0.913, 22 => 0.924, 24 => 0.933 },
    :shade_intolerant => { 10 => 0.783, 12 => 0.829, 14 => 0.858, 16 => 0.878, 18 => 0.895, 20 => 0.908, 22 => 0.917, 24 => 0.924 }

  }


  def cubic_feet_to_board_feet(volume, size_class)
    volume * 12 * SCRIBNER_FACTOR[species_group][size_class]
  end


  def cubic_feet_to_cords(volume)
    volume / 128.0
  end
end
