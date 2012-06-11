FactoryGirl.define do
  factory :listing do
    owner { FactoryGirl.create :player }
    megatile_grouping { FactoryGirl.create :megatile_grouping, single_megatile: true, owner: owner }
    price 100
  end
end

