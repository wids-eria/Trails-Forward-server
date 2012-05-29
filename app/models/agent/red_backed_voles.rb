class RedBackedVole

=begin
Habitat_suitability barren_land: 0,
                    coniferous_forest: 1,
                    cultivated_crops: 0,
                    deciduous_forest: 1,
                    developed_high_intensity: 0,
                    developed_low_intensity: 0,
                    developed_medium_intensity: 0,
                    developed_open_space: 0,
                    emergent_herbaceous_wetlands: 0,
                    excluded: 0,
                    grassland_herbaceous: 0,
                    mixed_forest: 1,
                    open_water: 0,
                    pasture_hay: 0,
                    shrub_scrub: 0,
                    woody_wetlands: 1
=end

def grow_voles 
  case day_of_year
    when 80..355
      vole_max_pop = 13.9  # fall max dens of Myodes gapperi - reported in Boonstra and Krebs 2012
      vole_growth_rate = (delta_spring_to_fall * (1 - (vole_population / vole_max_pop))) 
    else
     vole_max_pop = 5 # spring max dens of Myodes gapperi - reported in Boonstra and Krebs 2012
     vole_growth_rate = (delta_fall_to_spring * (1 - (vole_population / vole_max_pop))) 
  end
  vole_population = (vole_population + (vole_population * vole_growth_rate))
end

  
  
  def vole_tick
    if habitat_suitability_for "tile.here" == 1
      grow_voles
    else
      vole_population = 0 
    end
  end

end

