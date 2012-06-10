class WorldTurn
  attr_accessor :world, :turn_duration

  def initialize options = {}
    self.world = options[:world]
    self.turn_duration = 5.minutes
  end

  def can_process_turn?
    world.players.all? do |player|
      played_current_turn = player.last_turn_played == world.current_turn

      time_has_elapsed = DateTime.now > elapse_time

      played_current_turn || time_has_elapsed
    end
  end

  def time_left
    time_left = (elapse_time - DateTime.now) * 1.days
    time_left.round
  end

  def elapse_time
    world.turn_started_at.to_datetime + turn_duration
  end

  def turn
    transfer_money
    grow_trees
    marten_simulation
    land_desirability
    migrate_people
    advance_turn
  end

  def transfer_money
    world.players.each do |player|
      player.balance += player.pending_balance
      player.pending_balance = 0
      player.save!
    end
  end

  def grow_trees
    world.grow_trees!
  end

  def land_desirability
    world.update_total_desirability_scores!
  end

  def migrate_people
     world.migrate_population_to_most_desirable_tiles! 5000
  end

  def marten_simulation
    world.update_marten_suitability_and_count_of_suitable_tiles
  end

  def advance_turn
    world.current_turn += 1
    world.turn_started_at = DateTime.now
    # TODO change state
  end
end


# cron, set turn flag on worlds (ready to tick)
# cron, fire jobs?
