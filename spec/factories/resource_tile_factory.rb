FactoryGirl.define do
  factory :resource_tile do
    world
    megatile { Factory.create(:megatile, world: world) }
  end
end
