module TrailsForward
  module TileCreationUtilities
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

    def tree_density_percent density
      return 0.0 if density == 255.0
      density / 100.0
    end

    def housing_density_percent density
      case density
      when 1..6 then (2 ** (density + 1)) / 128.0
      else 0.0
      end
    end

    def imperviousness_percent density
      return 0.0 if density == 255.0
      density / 100.0
    end

    def soil_amount amount
      return nil if amount == 255
      amount
    end

    def determine_tree_size land_cover_type
      case land_cover_type
      when 'Coniferous', 'Deciduous', 'Forested Wetland', 'Mixed'
        cover_type_symbol = land_cover_type.underscore.sub(' ', '_').to_sym
        calculate_tree_size cover_type_symbol
      when'Dwarf Scrub', 'Grassland/Herbaceous', 'Shrub/Scrub'
        nil
        # tile.update_attributes(tree_size: nil)
      when nil
        nil
      else
        raise "Unrecognized land_cover_type: #{land_cover_type}"
      end
    end

    def calculate_tree_size cover_type_symbol
      if cover_type_symbol.present?
        tree_size = random_element(DefaultTreeSizes, DefaultTreeSizeWeights[cover_type_symbol])

        if tree_size == 10
          tree_size += random_element(BigTreeSizes, BigTreeSizeWeights[cover_type_symbol])
        end
      else
        tree_size = nil
      end
      tree_size
    end


    def developed_but_not_lived_in? tile_hash
      (tile_hash[:development_intensity] >= 0.5 || tile_hash[:imperviousness] >= 0.5) && tile_hash[:housing_density] <= 0.75
    end

    def primary_use tile_hash
      case tile_hash[:landcover_class_code]
      when 11, 95 # Open Water, Emergent Herbaceous Wetlands
        'Housing' if tile_hash[:housing_density] > 0
      when 21..24 # Developed
        developed_but_not_lived_in?(tile_hash) ? "Industry" : "Housing"
      when 41,42,43,51,52,71,90 # Forest types
        "Forest"
      when 81
        'Agriculture/Pasture'
      when 82
        'Agriculture/Cultivated Crops'
      end
    end

    def tile_type(tile_hash)
      case tile_hash[:landcover_class_code]
      when 11, 95 # Open Water, Emergent Herbaceous Wetlands
        if tile_hash[:housing_density] <= 0
          'MongoWaterTile'
        else
          'MongoLandTile'
        end
      when 255 # Off the end of the world, Water for now
        'MongoWaterTile'
      else
        'MongoLandTile'
      end
    end

  end
end
