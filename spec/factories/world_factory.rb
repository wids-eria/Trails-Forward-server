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
      world.spawn_blank_tiles
    end
  end

  factory :world_with_resources, parent: :world do
    after_create do |world, proxy|
      world.spawn_blank_tiles true
    end
  end

  factory :world_with_players, parent: :world do
    after_create do |world, proxy|
      world.spawn_blank_tiles true
      world.create_users_and_players
    end
  end

  factory :world_with_properties, parent: :world do
    after_create do |world, proxy|
      world.spawn_blank_tiles true
      world.create_users_and_players
      world.create_starter_properties
    end
  end

  factory :vilas, parent: :world do
    name { "Vilas County, WI - #{rand(100000)}" }
    year_start 2000
    year_current 2001
    width 1353
    height 714
    megatile_width 3
    megatile_height 3
  end
end
