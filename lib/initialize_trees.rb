require 'stats_utilities'

# TODO: revisit forested_wetland weights, since the values here are simply
# copied from mixed. 12/30/11

DefaultTreeSizes = [10, 8, 5]
DefaultTreeSizeWeights = {
  coniferous: [0.556035896, 0.258728096, 0.185236008],
  deciduous: [0.43, 0.37, 0.2],
  forested_wetland: [0.424745355, 0.350450241, 0.224804403],
  mixed: [0.424745355, 0.350450241, 0.224804403]
}

BigTreeSizes = [0,2,4,6,8,10,15,20]
BigTreeSizeWeights = {
  coniferous: [0.372470808,0.216336587,0.104601339,0.107220868,0.063811891,0.053101396,0.079521954,0.002935158],
  deciduous: [0.473433437,0.271229523,0.127051152,0.068338135,0.029715297,0.011826016,0.01840644,0],
  forested_wetland: [0.369033307,0.232593812,0.114078886,0.10555826,0.061401365,0.046739204,0.068313732,0.002281434],
  mixed: [0.369033307,0.232593812,0.114078886,0.10555826,0.061401365,0.046739204,0.068313732,0.002281434],
}

def seed_trees(world)
  world.resource_tiles.find_in_batches do |group|
    group.each do |tile|
      case tile.tree_species
      when 'Coniferous', 'Deciduous', 'Forested Wetland', 'Mixed'
        cover_type_symbol = tile.tree_species.underscore.sub(' ', '_').to_sym
        tile.update_attributes(tree_size: determine_tree_size(cover_type_symbol))
      when'Dwarf Scrub', 'Grassland/Herbaceous', 'Shrub/Scrub'
        tile.update_attributes(tree_size: nil)
      when nil
      else
        raise "Unrecognized tree_species: #{tile.tree_species}"
      end
    end
  end
end

def determine_tree_size cover_type_symbol
  if cover_type_symbol.present?
    tree_size = random_element(DefaultTreeSizeWeights[cover_type_symbol], DefaultTreeSizes)

    # puts "#{tile.x}, #{tile.y}: tree size = #{tile.tree_size}"
    if tree_size == 10
      tree_size += random_element(BigTreeSizeWeights[cover_type_symbol], BigTreeSizes)
    end
  else
    tree_size = nil
  end
  tree_size
end
