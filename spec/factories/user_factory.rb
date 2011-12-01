FactoryGirl.define do
  sequence :email do |n|
    "test_#{n}@example.com"
  end
end

FactoryGirl.define do
  factory :user do
    name "Bob Dole"
    email
    password "password"
  end
end
