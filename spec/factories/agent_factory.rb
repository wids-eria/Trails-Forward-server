FactoryGirl.define do
  factory :agent do
    association(:world) { create :world_with_tiles }
  end
end
