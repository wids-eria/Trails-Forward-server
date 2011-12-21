class Tribble < Agent
  def go
    reproduce if should_reproduce?
    move(rand(2) + 1) if should_move?
    turn(rand(90) - 45)
  end

  def litter_size
    10
  end

  def life_expectancy
    10
  end

  def should_die?
    rand < 1 / (1 + Math::E ** (-(5.0 / life_expectancy) * (self.age - life_expectancy)))
  end

  def max_view_distance
    4
  end

  def max_move_rate
    2
  end

  def should_reproduce?
    nearby_peers.count <= max_neighbors_to_reproduce
  end

  def should_move?
    nearby_tiles
    nearby_peers.count > move_threshold || fidget?
  end

  def fidget?
    rand < 0.3
  end

  def move_threshold
    1
  end

  def max_neighbors_to_reproduce
    2
  end
end
