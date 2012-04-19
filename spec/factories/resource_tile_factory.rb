FactoryGirl.define do
  factory :resource_tile do
    zone_type :none
    landcover_class_code 255
    world
    megatile { Factory.create(:megatile, world: world) }

    factory :land_tile, class: LandTile do
      factory :forest_tile do
        tree_density 0.5
      end

      factory :grass_tile do
        tree_density nil
      end
    end

    factory :water_tile, class: LandTile do
      zoning_code 255
    end
  end
end
