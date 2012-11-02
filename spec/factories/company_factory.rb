FactoryGirl.define do
  factory :company do |c|
    c.sequence(:name) { |n| "Test Co. #{n}" }
    c.sequence(:codename) { |n| "TestCo#{n}" }
  end
end
