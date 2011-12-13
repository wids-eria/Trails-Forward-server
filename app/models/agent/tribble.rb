class Tribble < Agent
  def tick
    move 1 if should_move?
  end

  def should_move?
    nearby_peers.count > move_threshold
  end

  def move_threshold
    1
  end
end
