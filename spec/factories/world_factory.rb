# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :world do
    sequence(:name) {|n| "Example World #{n}"}
    year_start 1880
    year_current 1880
    width 6
    height 6
    megatile_width 3
    megatile_height 3
  end
end
