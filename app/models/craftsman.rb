class Craftsman
  def build_single_family_home!(land_tile, payer = nil)
    payer = land_tile.megatile.owner if payer == nil
    wood_price = land_tile.world.pine_sawtimber_price
    land_tile.housing_type = "single family"
    land_tile.save!
    use_wood! land_tile.world, payer, square_feet_to_board_feet(1800), wood_price
  end
  
  def build_vacation_home!(land_tile, payer = nil)
    payer = land_tile.megatile.owner if payer == nil
    wood_price = land_tile.world.pine_sawtimber_price
    land_tile.housing_type = "vacation"
    land_tile.save!
    use_wood! land_tile.world, payer, square_feet_to_board_feet(2500), wood_price
  end
  
  def build_apartment!(land_tile, payer = nil)
    payer = land_tile.megatile.owner if payer == nil
    wood_price = land_tile.world.pine_sawtimber_price
    land_tile.housing_type = "apartment"
    land_tile.save!
    use_wood! land_tile.world, payer, square_feet_to_board_feet(21600), wood_price    
  end
  
  def square_feet_to_board_feet(sqft)
    9.54 * sqft
  end
  
  def use_wood!(world, player, bdft, wood_price)
    World.update_counters world.id, :pine_sawtimber_used_this_turn => bdft
    Player.update_counters player.id, :balance => (0-wood_price * bdft)
  end
end