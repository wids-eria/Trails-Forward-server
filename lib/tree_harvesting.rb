module TreeHarvesting
    def self.included(base)
      base.extend ClassMethods
    end
    module ClassMethods
    end

    def trees_in_size(tree_size)
      self.send "num_#{tree_size}_inch_diameter_trees"
    end

    def set_trees_in_size(tree_size, value)
      self.send "num_#{tree_size}_inch_diameter_trees=", value
    end

    def sawyer target_diameter_distribution
      tree_sizes.each_with_index do |tree_size, index|
        if trees_in_size(tree_size) > target_diameter_distribution[index]
          set_trees_in_size(tree_size, target_diameter_distribution[index])
        end
      end
    end


    def diameter_limit_cut options
      size_counts = collect_tree_size_counts

      if options[:above].present?
        size_counts.fill(0, ((options[:above]/2)..-1)) 
        sawyer size_counts
      elsif options[:below].present?
        size_counts.fill(0, (0...(options[:below]/2-1))) 
        sawyer size_counts
      end
    end
end
