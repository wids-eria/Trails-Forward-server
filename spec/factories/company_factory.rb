FactoryGirl.define do
  factory :company do |c|
    c.sequence(:name) { |n| "Test Co. #{n}"}
  end
end
