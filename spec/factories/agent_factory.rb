FactoryGirl.define do
  factory :agent do
    association(:world) { create :world_with_tiles }
    location [1,1]
    heading 0
  end

  factory(:flycatcher, class: Flycatcher, parent: :agent) {}
  factory(:generic_agent, class: GenericAgent, parent: :agent) {}
  factory(:red_fox, class: RedFox, parent: :agent) {}
  factory(:tribble, class: Tribble, parent: :agent) {}
end
