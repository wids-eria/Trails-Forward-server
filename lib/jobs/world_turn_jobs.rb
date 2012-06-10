require File.expand_path("../../../config/environment", __FILE__)
require 'stalker'

def pool_name(world_id, pool)
  "world.#{world_id}.#{pool}.complete"
end

Stalker.job 'resource_tile.grow_trees' do |args|

    tile = ResourceTile.find args['resource_tile_id']
    tile.grow_trees! if tile.can_clearcut?

    tree_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(tile.world_id, :trees))
    tree_complete_stalk.put(tile.id)
end

Stalker.job 'resource_tile.marten_suitability' do |args|

    tile = ResourceTile.find args['resource_tile_id']
    tile.calculate_marten_suitability

    marten_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(tile.world_id, :marten))
    marten_complete_stalk.put(tile.id)
end

Stalker.job 'resource_tile.desirability' do |args|
    tile = ResourceTile.find args['resource_tile_id']
    tile.update_total_desirability_score!

    desirability_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(tile.world_id, :desirability))
    desirability_complete_stalk.put(tile.id)
end
