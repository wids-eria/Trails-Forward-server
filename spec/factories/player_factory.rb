FactoryGirl.define do
  factory :player do
    user
    world { Factory :world_with_properties }
    balance { Player.default_balance }

    last_turn_played_at { DateTime.now }
  end

  factory(:lumberjack, class: Lumberjack, parent: :player) {}
  factory(:developer,  class: Developer,  parent: :player) {}
  factory(:conserver,  class: Conserver,  parent: :player) {}
end
