class WorldTicker
  attr_accessor :world

  def initialize options = {}
    self.world = options[:world]
  end

  def can_process_turn?
    players_ready = world.players.all? do |player|
      player.last_turn_played == world.current_turn - 1
    end
  end
end
