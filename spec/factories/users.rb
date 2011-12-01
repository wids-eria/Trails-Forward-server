FactoryGirl.define do
  factory :user do
    name "Bob Dole"
    sequence(:email) { |n| "test_#{n}@example.com" }
    password "password"
  end
end
