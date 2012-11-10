class Pricing
  def initialize(world)
    @world = world
  end


  def pine_sawtimber_price
    computed_price = @world.pine_sawtimber_base_price - (@world.pine_sawtimber_supply_coefficient * @world.pine_sawtimber_cut_this_turn) + (@world.pine_sawtimber_demand_coefficient * @world.pine_sawtimber_used_this_turn)
  	[[@world.pine_sawtimber_min_price, computed_price].max, @world.pine_sawtimber_max_price].min
  end



  # HARVESTING
  #
  # TODO expose as db level configuration with defaults.
  def self.clearcut_cost resource_tiles
    resource_tiles.collect{|tile| self.individual_clearcut_cost tile}.sum
  end

  def self.individual_clearcut_cost resource_tile
    5
  end


  def self.partial_selection_cost resource_tiles
    5 * resource_tiles.count
  end


  def self.diameter_limit_cost resource_tiles
    5 * resource_tiles.count
  end
end
