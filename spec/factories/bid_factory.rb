FactoryGirl.define do
  factory :bid do
    requested_land_id { Factory.create :megatile_grouping, single_megatile: true }
    money 100
  end
end
