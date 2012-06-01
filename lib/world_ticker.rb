class WorldTicker
  attr_accessor :world

  def initialize options = {}
    self.world = options[:world]
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
    world.turn_started_at.to_datetime + 30.minutes
  end
end
