class SpacerTurtle < Tortuga
  def tick
    look_around
    if not happy?
      wiggle
    end
  end
  
  def view_distance
    10
  end

  def comfort_distance
    5
  end

  def look_around
    patches_in_radius(view_distance)
    
  end
  
  def happy?
    neighbors = turtles_of_species_in_radius(:SpacerTurtle, comfort_distance)
    neighbors.count == 0
  end
  
  def wiggle
    turn_right rand(20)
    forward 3
  end
end
