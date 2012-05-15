FactoryGirl.define do
  factory :player do
    user
    world { Factory :world_with_properties }
    balance { Player.default_balance }
  end

  factory(:lumberjack, class: Lumberjack, parent: :player) {}
  factory(:developer,  class: Developer,  parent: :player) {}
  factory(:conserver,  class: Conserver,  parent: :player) {}
end
