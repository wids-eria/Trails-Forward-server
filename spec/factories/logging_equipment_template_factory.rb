FactoryGirl.define do
  factory :logging_equipment_template do
    sequence(:name) {|n| "logging_equipment_#{n}" }
    equipment_type "Harvester"
    market_description "Its really nice"
    initial_cost_min   { rand(10) }
    initial_cost_max   { rand(10) + initial_cost_min }
    operating_cost_min { rand(10) }
    operating_cost_max { rand(10) + operating_cost_min }
    maintenance_cost_min { rand(10) }
    maintenance_cost_max { rand(10) + maintenance_cost_min }
    harvest_volume_min { rand(10) }
    harvest_volume_max { rand(10) + harvest_volume_min }
    diameter_range_min { rand(10) }
    diameter_range_max { rand(10) + diameter_range_min }
    yarding_volume_min { rand(10) }
    yarding_volume_max { rand(10) + yarding_volume_min }
    transport_volume_min { rand(10) }
    transport_volume_max { rand(10) + transport_volume_min }
    condition_min { rand(10) }
    condition_max { rand(10) + condition_min }
    reliability_min { rand(10) }
    reliability_max { rand(10) + reliability_min }
    decay_rate_min { rand(10) }
    decay_rate_max { rand(10) + decay_rate_min }
    scrap_value_min { rand(10) }
    scrap_value_max { rand(10) + scrap_value_min }
  end
end
