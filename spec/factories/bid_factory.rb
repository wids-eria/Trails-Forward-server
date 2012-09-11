FactoryGirl.define do
  factory :bid do
    requested_land_id { FactoryGirl.create :megatile_grouping, single_megatile: true }
    money 100
    trait :offered_land do
      offered_land_id { FactoryGirl.create :megatile_grouping, single_megatile: true }
    end

    factory :bid_with_offered_land, traits: [:offered_land]
  end
end
