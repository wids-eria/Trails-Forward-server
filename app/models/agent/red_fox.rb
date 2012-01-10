class RedFox < Agent
  include Behavior::TransitionMatrix
  include Behavior::HabitatSuitability

  transition_matrix [[0,    1.49],
                     [0.48, 0.48]]

  habitat_suitability barren_land: 0,
                      coniferous_forest: 4,
                      cultivated_crops: 5,
                      deciduous_forest: 8.5,
                      developed_high_intensity: 0,
                      developed_low_intensity: 4,
                      developed_medium_intensity: 2,
                      developed_open_space: 5,
                      emergent_herbaceous_wetlands: 0,
                      grassland_herbaceous: 8,
                      mixed_forest: 6,
                      open_water: -1,
                      pasture_hay: 6,
                      shrub_scrub: 10,
                      excluded: 0,
                      woody_wetlands: 0

  suitability_survival_modifier do |suitability_rating|
    1 - (1 - suitability_rating / 10.0) ** 3
  end

  suitability_fecundity_modifier do |suitability_rating|
    suitability_rating / 10.0
  end

  max_view_distance 1

  move_when { true }

  move_to do |agent|
    agent.best_nearby_tile.center_location
  end

  tile_utility do |agent, tile|
    agent.suitability_survival_modifier_for tile
  end
end
