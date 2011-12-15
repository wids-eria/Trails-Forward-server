FactoryGirl.define do
  factory :agent do
    association(:world) { create :world_with_tiles }
    location [1,1]
    heading 0
  end

  factory :tribble, class: Tribble, parent: :agent do
  end

  factory :generic_agent, class: GenericAgent, parent: :agent do
  end
end
