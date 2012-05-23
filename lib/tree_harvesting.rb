# TODO make into its own Sawyer class.. no need to be a mixin really if its dealing
# with lists of sizes that can be passed to it.
#

module TreeHarvesting
    def self.included(base)
      base.extend ClassMethods
    end
    module ClassMethods
    end


    def calculate_product_values_and_volumes_for target_diameter_distribution
      excess_tree_counts = excess_tree_counts target_diameter_distribution

      poletimber_value  = poletimber_sizes.collect{|size| estimated_tree_value_for_size size, excess_tree_counts[position_for_size(size)] }.sum
      poletimber_volume = poletimber_sizes.collect{|size| estimated_tree_volume_for_size size, excess_tree_counts[position_for_size(size)] }.sum

      sawtimber_value  = sawtimber_sizes.collect{|size| estimated_tree_value_for_size size, excess_tree_counts[position_for_size(size)] }.sum
      sawtimber_volume = sawtimber_sizes.collect{|size| estimated_tree_volume_for_size size, excess_tree_counts[position_for_size(size)] }.sum

      {poletimber_value: poletimber_value, poletimber_volume: poletimber_volume, sawtimber_value: sawtimber_value, sawtimber_volume: sawtimber_volume}
    end


    def position_for_size tree_size
      tree_size / 2 - 1
    end


    def excess_tree_counts target_diameter_distribution
      arr = []
      tree_sizes.each_with_index do |tree_size, index|
        if trees_in_size(tree_size) > target_diameter_distribution[index]
          arr.push trees_in_size(tree_size) - target_diameter_distribution[index]
        else
          arr.push 0
        end
      end
      arr
    end


    def sawyer target_diameter_distribution
      values_and_volumes = calculate_product_values_and_volumes_for target_diameter_distribution

      tree_sizes.each_with_index do |tree_size, index|
        if trees_in_size(tree_size) > target_diameter_distribution[index]
          set_trees_in_size(tree_size, target_diameter_distribution[index])
        end
      end
      values_and_volumes
    end


    def diameter_limit_cut options
      size_counts = collect_tree_size_counts

      if options[:above].present?
        size_counts.fill(0, ((options[:above].to_i/2)..-1)) 
        sawyer size_counts
      elsif options[:below].present?
        size_counts.fill(0, (0...(options[:below].to_i/2-1))) 
        sawyer size_counts
      end
    end


    def partial_selection_curve options
      raise 'needs arguments' if options[:qratio].blank? || options[:target_basal_area].blank?
      qratio = options[:qratio].to_f
      target_basal_area = options[:target_basal_area].to_f

      individual_basal_area = tree_sizes.collect{|tree_size| basal_area_for_size(tree_size) }

      normalized_target_diameter_distribution = tree_sizes.count.times.collect{|n| qratio**n}.reverse

      normalized_target_diameter_distribution_basal_area_sum = tree_sizes.count.times.collect do |index|
        normalized_target_diameter_distribution[index] * individual_basal_area[index]
      end.sum

      target_diameter_distribution = normalized_target_diameter_distribution.collect do |distribution|
        distribution * (normalized_target_diameter_distribution_basal_area_sum / target_basal_area)
      end
    end


    def partial_selection_cut options
      vector = partial_selection_curve options
      sawyer vector
    end

    def clearcut
      sawyer collect_tree_size_counts.map{ 0 }
    end

end
