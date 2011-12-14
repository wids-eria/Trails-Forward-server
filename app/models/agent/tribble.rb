class Tribble < Agent
  def tick
    self.delete and return if should_die?

    reproduce if should_reproduce?

    move(rand(2) + 1) if should_move?

    turn(rand(90) - 45)
  end

  def max_view_distance
    4
  end

  def should_die?
    rand() < 0.1
  end

  def should_reproduce?
    nearby_peers.count <= reproduce_threshold
  end

  def should_move?
    nearby_tiles
    nearby_peers.count > move_threshold || rand < 0.3
  end

  def move_threshold
    1
  end

  def reproduce_threshold
    2
  end

  def reproduce
    10.times do
      offspring = self.class.create world_id: world_id,
        resource_tile_id: resource_tile_id,
        heading: rand(360).round
      offspring.location = location
      offspring.save
    end
  end
end
