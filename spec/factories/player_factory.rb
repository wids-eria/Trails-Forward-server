FactoryGirl.define do
  factory :player do
    user
    world { $world ||= Factory :world_with_properties }
    balance 100
  end
end
