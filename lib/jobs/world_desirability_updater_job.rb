require File.expand_path("../../../config/environment", __FILE__)
require 'stalker'
include Stalker


job 'resource_tile.update_total_desirability' do |args|
  rt = ResourceTile.find args["resource_tile_id"]
  update_resource_tile_total_desirability(rt)
end

job 'resource_tiles.update_total_desirability' do |args|
  rts = ResourceTile.find args["resource_tile_ids"]
  rts.each do |rt|
    rt.update_total_desirability_score!
  end
end
