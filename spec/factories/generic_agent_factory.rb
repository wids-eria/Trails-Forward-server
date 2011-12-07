FactoryGirl.define do
  factory :generic_agent do
    association(:world) { create :world_with_tiles }
  end
end
