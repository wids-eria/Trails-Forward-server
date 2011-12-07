FactoryGirl.define do
  factory :megatile do
    sequence(:x) { |n| n }
    sequence(:y) { |n| n }
    world { Factory.create :world }
  end
end
