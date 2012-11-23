class TimeManager

  # Time logic for performing all actions
  #

  def self.can_perform_action? options
    options.required_keys! :player, :cost

    # Need a positive balance before considering cost.
    return false if options[:player].time_remaining_this_turn <= 0

    # Can drop balance to 0
    (options[:player].time_remaining_this_turn - options[:cost]) >= 0
  end



  # CLEARCUT #############################
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
    harvest_ability = LoggingEquipment.harvest_volume_for(diameter: options[:diameter], equipment: options[:player].logging_equipment)

    volume = options[:tile].send("estimated_#{options[:diameter]}_inch_tree_volume")

    return 0.0 if volume == 0.0
    return 0.0 if harvest_ability == 0.0
    volume / harvest_ability
  end



  # PARTIAL SELECTION ####################
  #

  def self.partial_selection_cost options
    options[:tiles].collect do |tile|
      partial_selection_cost_for_tile options.except(:tiles).merge(tile: tile)
    end.sum
  end

  def self.partial_selection_cost_for_tile options
    LandTile.tree_sizes.collect do |size|
      partial_selection_cost_for_diameter options.merge(diameter: size)
    end.sum
  end

  def self.partial_selection_cost_for_diameter options
    harvest_ability = LoggingEquipment.harvest_volume_for(diameter: options[:diameter], equipment: options[:player].logging_equipment)

    volume = options[:tile].send("estimated_#{options[:diameter]}_inch_tree_volume")

    return 0.0 if volume == 0.0
    return 0.0 if harvest_ability == 0.0
    volume / harvest_ability
  end



  # DIAMETER LIMIT #######################
  #

  def self.diameter_limit_cost options
    options[:tiles].collect do |tile|
      diameter_limit_cost_for_tile options.except(:tiles).merge(tile: tile)
    end.sum
  end

  def self.diameter_limit_cost_for_tile options
    LandTile.tree_sizes.collect do |size|
      diameter_limit_cost_for_diameter options.merge(diameter: size)
    end.sum
  end

  def self.diameter_limit_cost_for_diameter options
    harvest_ability = LoggingEquipment.harvest_volume_for(diameter: options[:diameter], equipment: options[:player].logging_equipment)

    volume = options[:tile].send("estimated_#{options[:diameter]}_inch_tree_volume")

    return 0.0 if volume == 0.0
    return 0.0 if harvest_ability == 0.0
    volume / harvest_ability
  end
end
