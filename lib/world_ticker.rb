class WorldTicker
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

    self.world.current_turn += 1
    self.world.turn_started_at = DateTime.now
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

  def marten_simulation
    world.update_marten_suitability_and_count_of_suitable_tiles
  end
end
