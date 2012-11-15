class TimeManager

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

  def self.can_perform_action? player
    player.time_remaining_this_turn >= 0
  end
end
