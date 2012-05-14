FactoryGirl.define do
  factory :resource_tile do
    zone_type :none
    landcover_class_code { ResourceTile.cover_type_number(:excluded) }
    world
    megatile { Factory.create(:megatile, world: world) }

    factory :land_tile, class: LandTile do
      landcover_class_code { ResourceTile.cover_type_number(:barren) }

      factory :grass_tile do
        tree_density nil
        landcover_class_code { ResourceTile.cover_type_number(:grassland_herbaceous) }
      end


      # gutted from world_generation.rb
      factory :deciduous_land_tile, aliases: [:forest_tile] do
        primary_use nil
        people_density 0
        housing_density 0
        tree_density { 0.5 + rand / 2.0 }
        tree_size 12.0
        num_2_inch_diameter_trees 2
        num_4_inch_diameter_trees 4
        num_6_inch_diameter_trees 6
        num_8_inch_diameter_trees 8
        num_10_inch_diameter_trees 10
        num_12_inch_diameter_trees 12
        num_14_inch_diameter_trees 10
        num_16_inch_diameter_trees 8
        num_18_inch_diameter_trees 6
        num_20_inch_diameter_trees 4
        num_22_inch_diameter_trees 2
        num_24_inch_diameter_trees 0
        landcover_class_code { ResourceTile.cover_type_number(:deciduous) }
        development_intensity 0.0
        zoning_code 6
      end

      factory :deciduous_land_tile_variant do
        primary_use nil
        people_density 0
        housing_density 0
        tree_density { 0.5 + rand / 2.0 }
        tree_size 12.0
        num_2_inch_diameter_trees 48
        num_4_inch_diameter_trees 28
        num_6_inch_diameter_trees 22
        num_8_inch_diameter_trees 18
        num_10_inch_diameter_trees 14
        num_12_inch_diameter_trees 12
        num_14_inch_diameter_trees 10
        num_16_inch_diameter_trees 8
        num_18_inch_diameter_trees 6
        num_20_inch_diameter_trees 4
        num_22_inch_diameter_trees 2
        num_24_inch_diameter_trees 0
        landcover_class_code { ResourceTile.cover_type_number(:deciduous) }
        development_intensity 0.0
        zoning_code 6
      end

      factory :residential_land_tile do
        primary_use "Residential"
        zoning_code 12
        people_density { 0.5 + rand / 2.0 }
        housing_density { people_density }
        tree_density { rand * 0.1 }
        num_2_inch_diameter_trees 48
        num_4_inch_diameter_trees 28
        num_6_inch_diameter_trees 22
        num_8_inch_diameter_trees 18
        num_10_inch_diameter_trees 14
        num_12_inch_diameter_trees 12
        num_14_inch_diameter_trees 10
        num_16_inch_diameter_trees 8
        num_18_inch_diameter_trees 6
        num_20_inch_diameter_trees 4
        num_22_inch_diameter_trees 2
        num_24_inch_diameter_trees 0
        development_intensity { people_density }
      end
    end

    factory :water_tile, class: WaterTile do
      zoning_code 255
    end
  end
end
