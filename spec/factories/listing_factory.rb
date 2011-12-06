FactoryGirl.define do
  factory :listing do
    owner { Factory.create :player }
    megatile_grouping { Factory.create :megatile_grouping, single_megatile: true, owner: owner }
    price 100
  end
end

