FactoryGirl.define do
  factory :resource_tile do
    world
    megatile { Factory.create(:megatile, world: world) }
  end

  factory(:land_tile, class: LandTile, parent: :resource_tile) {}
  factory(:water_tile, class: WaterTile, parent: :resource_tile) {}
end
