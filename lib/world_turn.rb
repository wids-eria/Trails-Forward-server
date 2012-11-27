class WorldTurn
  attr_accessor :world, :turn_duration

  # add player default time here (or read it from world..

  def initialize options = {}
    self.world = options[:world]
    self.turn_duration = world.turn_duration.minutes
  end

  def can_process_turn?
    return false if world.players.empty?
    time_has_elapsed = DateTime.now > elapse_time
    time_has_elapsed
  end

  def time_left
    time_left = (elapse_time - DateTime.now) * 1.days
    time_left.round
  end

  def elapse_time
    world.turn_started_at.to_datetime + turn_duration
  end

  # A single turn, use background jobs instead if you want parallel
  def turn
    transfer_money
    repo_man
    replenish_player_time
    grow_trees
    marten_simulation
    land_desirability
    advance_turn
  end

  def transfer_money
    world.players.each do |player|
      player.balance += player.pending_balance
      player.pending_balance = 0
      player.save!
    end
  end

  def repo_man
    RepoMan.visit_players! world
  end

  def replenish_player_time
    TimeManager.replenish_players_time! world
  end

  def grow_trees
    world.grow_trees!
  end

  def land_desirability
    world.update_total_desirability_scores!
  end

  def marten_simulation
    world.update_marten_suitability_and_count_of_suitable_tiles
  end

  def mark_for_processing
    world.turn_state = "ready_for_processing"
  end

  def processing
    world.turn_state = "processing"
  end

  def advance_turn
    world.current_turn += 1
    world.turn_started_at = DateTime.now
    world.current_date += 4.years
    world.turn_state = "playing"
    # TODO change state
  end
end


# cron, set turn flag on worlds (ready to tick)
# cron, fire jobs?
