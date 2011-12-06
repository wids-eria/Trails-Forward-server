FactoryGirl.define do
  factory :tribble do
    association(:world) { create :world_with_tiles }
  end
end
