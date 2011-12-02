require 'example_world_builder'

FactoryGirl.define do
  factory :player do
    user
    world { $world ||= ExampleWorldBuilder.build_example_world }
    balance 100
  end
end
