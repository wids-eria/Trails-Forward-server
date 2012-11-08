class TimeManager

  def self.clearcut_cost options
    10
  end

  def self.can_perform_action? player
    player.time_remaining_this_turn >= 0
  end
end
