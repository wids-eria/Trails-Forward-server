class YoungdaeTileMatcher < LoggerTileMatcher
  def find_tiles(contract)
    world = contract.world
    acceptable_tiles = []
    lots_of_megatiles = world.megatiles.where(:owner_id => nil).shuffle[0..50]

    lots_of_megatiles.each do |megatile|
      megatile.resource_tiles.where(:type => "LandTile").each do |resource_tile|
        begin
          if resource_tile.total_wood_values_and_volumes[:sawtimber_volume] > contract.contract_template.volume_required
            acceptable_tiles << resource_tile
          end
        rescue
          next
        end
      end
    end
    acceptable_tiles
  end

  def find_and_attach_to_contract_with_player(contract)
    resource_tiles = find_tiles(contract).shuffle
    if resource_tiles.count == 0
      raise "no tiles found"
    end

    resource_tile_to_use =  resource_tiles.first
    megatile = resource_tile_to_use.megatile
    megatile.owner = contract.player
    if megatile.save
      contract.included_megatiles << resource_tile_to_use.megatile
      true
    else
      false
    end
  end
end