FactoryGirl.define do
  factory :megatile do
    world { Factory :world_with_properties }
  end
end
