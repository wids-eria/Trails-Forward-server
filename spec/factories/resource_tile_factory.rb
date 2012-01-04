FactoryGirl.define do
  factory :resource_tile do
    world
    megatile { Factory.create(:megatile, world: world) }
  end

  factory(:land_tile, class: LandTile, parent: :resource_tile) {}

  factory(:water_tile, class: WaterTile, parent: :resource_tile) do
    zoning_code 255
  end

  factory(:forest_tile, parent: :land_tile) do
    tree_density 0.5
  end

  factory(:grass_tile, parent: :land_tile) do
    tree_density nil
  end
end
