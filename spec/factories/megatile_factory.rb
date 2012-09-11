FactoryGirl.define do
  factory :megatile do
    sequence(:x) { |n| n }
    sequence(:y) { |n| n }
    world { FactoryGirl.create :world }
  end
end
