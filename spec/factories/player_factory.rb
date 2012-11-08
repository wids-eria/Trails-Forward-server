FactoryGirl.define do
  factory :player do
    user
    world { Factory :world_with_properties }
    balance { Player.default_balance }
    time_remaining_this_turn { Player.default_time_remaining }

    last_turn_played_at { DateTime.now }
  end

  factory(:lumberjack, class: Lumberjack, parent: :player) {}
  factory(:developer,  class: Developer,  parent: :player) {}
  factory(:conserver,  class: Conserver,  parent: :player) {}
end
