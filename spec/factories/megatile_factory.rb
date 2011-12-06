FactoryGirl.define do
  factory :megatile do
    world { Factory.create :world_with_properties }
  end
end
