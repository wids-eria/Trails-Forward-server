require 'stats_utilities'

def seed_trees(world)

  tree_size_values = [10, 8, 5]
  deciduous_tree_size_class_weights = [0.43, 0.37, 0.2]
  coniferous_tree_size_class_weights = [0.556035896, 0.258728096, 0.185236008]
  mixed_tree_size_class_weights = [0.424745355, 0.350450241, 0.224804403]

  big_tree_size_values = [0,2,4,6,8,10,15,20]
  deciduous_tree_size_weights = [0.473433437,0.271229523,0.127051152,0.068338135,0.029715297,0.011826016,0.01840644,0]
  coniferous_tree_size_weights = [0.372470808,0.216336587,0.104601339,0.107220868,0.063811891,0.053101396,0.079521954,0.002935158]
  mixed_tree_size_weights = [0.369033307,0.232593812,0.114078886,0.10555826,0.061401365,0.046739204,0.068313732,0.002281434]


  ResourceTile.where(:world_id => world.id).find_in_batches do |group|
    group.each do |rt|
      if "Coniferous" == rt.tree_species
        tree_size_class_weights = coniferous_tree_size_class_weights
        big_weights = coniferous_tree_size_class_weights
      elsif "Deciduous" == rt.tree_species
        tree_size_class_weights = deciduous_tree_size_class_weights
        big_weights = deciduous_tree_size_weights
      elsif "Mixed" == rt.tree_species
        tree_size_class_weights = mixed_tree_size_class_weights
        big_weights = mixed_tree_size_weights
      else
        #nothing to do here
      end

      if rt.tree_species != nil
        rt.tree_size = random_element tree_size_class_weights, tree_size_values
        #puts "Base tree_size = #{rt.tree_size}"
      else
        rt.tree_size = nil
      end

      #puts "#{rt.x}, #{rt.y}: tree size = #{rt.tree_size}"
      if 10 == rt.tree_size
        rt.tree_size += random_element big_weights, big_tree_size_values
      end
      #puts "\t#{rt.x}, #{rt.y}: #{rt.tree_size}"
      rt.save
    end
  end
end
