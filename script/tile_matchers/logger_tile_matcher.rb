require_relative('tile_matcher')

class LoggerTileMatcher < TileMatcher
  def find_resource_tiles_in_world(world_id, constraints)

  end
end

class FirstStepsTileMatcher < LoggerTileMatcher
  def find(contract)

  end

  def find_and_attach_to_contract(contract)
    tiles = find(contract)
    raise "not yet implemented"
  end
end