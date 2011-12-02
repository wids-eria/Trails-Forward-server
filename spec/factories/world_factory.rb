FactoryGirl.define do
  factory :world do
    sequence(:name) {|n| "Example World #{n}"}
    year_start 1880
    year_current 1880
    width 6
    height 6
    megatile_width 3
    megatile_height 3
  end

  factory :world_with_tiles, parent: :world do
    after_create do |world, proxy|
      world.spawn_tiles
    end
  end

  factory :world_with_resources, parent: :world do
    after_create do |world, proxy|
      world.spawn_tiles
      world.place_resources
    end
  end

  factory :world_with_players, parent: :world do
    after_create do |world, proxy|
      world.spawn_tiles
      world.place_resources
      world.create_users_and_players
    end
  end

  factory :world_with_properties, parent: :world do
    after_create do |world, proxy|
      world.spawn_tiles
      world.place_resources
      world.create_users_and_players
      world.create_starter_properties
    end
  end
end
