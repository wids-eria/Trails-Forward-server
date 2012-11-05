FactoryGirl.define do
  factory :world do
    sequence(:name) {|n| "Example World #{n}"}
    start_date Date.new(1800, 1, 1)
    current_date { |w| w.start_date }
    width 6
    height 6
    megatile_width 3
    megatile_height 3
    
    pine_sawtimber_base_price  0.147
    pine_sawtimber_supply_coefficient  0.001
    pine_sawtimber_demand_coefficient  0.001
    pine_sawtimber_min_price  0.01
    pine_sawtimber_max_price  1.0
    pine_sawtimber_cut_this_turn  0
    pine_sawtimber_used_this_turn  0
    
    turn_started_at { DateTime.now }
  end

  factory :world_with_tiles, parent: :world do
    after_create do |world, proxy|
      world.spawn_blank_tiles populate: false
    end
  end

  factory :world_with_resources, parent: :world do
    after_create do |world, proxy|
      world.spawn_blank_tiles populate: true
    end
  end

  factory :world_with_players, parent: :world do
    after_create do |world, proxy|
      world.spawn_blank_tiles populate: true
      world.create_users_and_players
    end
  end

  factory :world_with_properties, parent: :world do
    after_create do |world, proxy|
      world.spawn_blank_tiles populate: true
    end
  end

  factory :world_with_properties_and_users, parent: :world do
    after_create do |world, proxy|
      world.spawn_blank_tiles populate: true
      world.create_users_and_players
      world.create_starter_properties
    end
  end

  factory :vilas, parent: :world do
    name { "Vilas County, WI - #{rand(100000)}" }
    start_date Date.new(2000, 1, 1)
    width 1353
    height 714
    megatile_width 3
    megatile_height 3
  end
end
