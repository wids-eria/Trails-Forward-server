class TribbleTortuga < Tortuga
  def go
    reproduce if should_reproduce?
    move(rand(2) + 1) if should_move?
    turn(rand(90) - 45)
  end

  def tile_pref_scale tile
    if tile.type == 'WaterTile'
      -0.1
    else
      (tile.tree_density + 1.0) / 2
    end
  end

  def tile_pref_vector tile
    vect = vector_to tile
    dist = vect.r
    vect = vect.normalize / dist
    vect * tile_pref_scale(tile)
  end

  def agent_pref_scale agent
    -0.25
  end

  def agent_pref_vector agent
    vect = vector_to agent
    dist = vect.r
    vect = vect.normalize / dist
    vect * agent_pref_scale(agent)
  end

  def most_desirable_heading
    Vector.sum(nearby_tile_preference_vectors + nearby_agent_preference_vectors)
  end

  def nearby_tile_preference_vectors
    nearby_tiles.map { |tile| tile_pref_vector tile }
  end

  def nearby_agent_preference_vectors
    nearby_agents.map { |agent| agent_pref_vector agent }
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
    child_bearing_range = (2..9)
    child_bearing_range.include?(self.age) &&
      (rand / 2) < self.resource_tile.tree_density &&
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
