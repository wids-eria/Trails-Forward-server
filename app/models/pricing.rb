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
  def self.clearcut_cost options
    options[:tiles].collect do |tile|
      clearcut_cost_for_tile options.except(:tiles).merge(tile: tile)
    end.sum
  end

  def self.clearcut_cost_for_tile options
    LandTile.tree_sizes.collect do |size|
      clearcut_cost_for_diameter options.merge(diameter: size)
    end.sum
  end

  def self.clearcut_cost_for_diameter options
    operation_cost = LoggingEquipment.operating_cost_for(diameter: options[:diameter], equipment: options[:player].logging_equipment)

    time_cost = TimeManager.clearcut_cost_for_diameter(diameter: options[:diameter], equipment: options[:player].logging_equipment)

    operation_cost * time_cost
  end


  # these will need parameters from the sawyer about whats actually getting cut.
  def self.partial_selection_cost resource_tiles
    5 * resource_tiles.count
  end


  def self.diameter_limit_cost resource_tiles
    5 * resource_tiles.count
  end
end
