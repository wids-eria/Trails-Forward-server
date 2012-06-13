require File.join(Rails.root, 'lib', 'jobs', 'world_turn_jobs')

module Jobs::WorldTurner
  def self.turn_a_world(world)
    log = Logger.new(File.join("log", "world_#{world.id}_turns"), 'daily')

            tree_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :trees))
          marten_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :marten))
    desirability_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :desirability))

    turn_manager = WorldTurn.new world: world

    log.info "World state: processing"
    turn_manager.processing
    world.save!

     # TREES
     land_tile_count = world.resource_tiles.limit(1000).land_tiles.count
     world.resource_tiles.limit(1000).land_tiles.each do |tile|
       Stalker.enqueue('resource_tile.grow_trees', resource_tile_id: tile.id)
     end

     log.info "Grow Trees"
     land_tile_count.times do |n|
       message = tree_complete_stalk.reserve
       log.info "trees: #{n}/#{land_tile_count}"
       message.delete
     end

     # MARTENS
     #Log.info "martens"  
     # Good news! no longer needed because this happens already as the trees are grown
     # world.resource_tiles.land_tiles.each do |tile|
     #   Stalker.enqueue('resource_tile.marten_suitability', resource_tile_id: tile.id)
     # end
     # 
     # world.resource_tiles.land_tiles.count.times do
     #   message = marten_complete_stalk.reserve
     #   message.delete
     # end

     # world.update_marten_suitable_tile_count

     # HOUSING
     resource_tile_count = world.resource_tiles.limit(1000).count
     world.resource_tiles.limit(1000).each do |tile|
       Stalker.enqueue('resource_tile.desirability', resource_tile_id: tile.id)
     end

     log.info "Desirability"
     resource_tile_count.times do |n|
       message = desirability_complete_stalk.reserve
       log.info "desire: #{n}/#{resource_tile_count}"
       message.delete
     end

     # PEOPLE
     log.info "People"
     turn_manager.migrate_people

     # MONEY
     log.info "Money"
     turn_manager.transfer_money

     # END TURN
     log.info "Advance"
     turn_manager.advance_turn

     log.info "Turn complete, world in play"
     world.save!

            tree_complete_stalk.close
          marten_complete_stalk.close
    desirability_complete_stalk.close

    turn_manager = WorldTurn.new world: world
  end
end
