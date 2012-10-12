class Craftsman
  def build_single_family_home!(land_tile)
    land_tile.save!
    use_wood! land_tile.world, square_feet_to_board_feet(1800)
  end
  
  def build_vacation_home!(land_tile)
    land_tile.save!
    use_wood! land_tile.world, square_feet_to_board_feet(2500)
  end
  
  def build_apartment!(land_tile)
    land_tile.save!
    use_wood! land_tile.world, square_feet_to_board_feet(21600)
  end
  
  def square_feet_to_board_feet(sqft)
    9.54 * sqft
  end
  
  def use_wood!(world, bdft)
    World.update_counters world.id, :pine_sawtimber_used_this_turn => bdft
  end
end