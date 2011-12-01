FactoryGirl.define do
  factory :megatile do
    world { $world ||= ExampleWorldBuilder.build_example_world(6,6) }
  end
end
