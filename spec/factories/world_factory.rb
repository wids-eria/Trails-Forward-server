# Read about factories at http://github.com/thoughtbot/factory_girl

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
      puts 1
      world.spawn_tiles
    end
  end

  factory :world_with_resources, parent: :world_with_tiles do
    after_create do |world, proxy|
      puts 2
      world.place_resources
    end
  end

  factory :world_with_players, parent: :world_with_resources do
    after_create do |world, proxy|
      puts 3
      world.create_users_and_players
    end
  end

  factory :world_with_properties, parent: :world_with_players do
    after_create do |world, proxy|
      puts 4
      world.create_starter_properties
    end
  end
end
