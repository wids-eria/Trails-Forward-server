require File.join(Rails.root, 'lib', 'jobs', 'world_turn_jobs')

ProgressBar.color_status
ProgressBar.iter_rate_mode

module Jobs::WorldTurner
  def self.turn_a_world(world)
    log = TimeStampLogger.new(File.join("log", "world_#{world.id}_turns"), 'daily')

            tree_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :trees))
          marten_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :marten))
    desirability_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :desirability))

    turn_manager = WorldTurn.new world: world

    log.info "World state: processing"
    turn_manager.processing
    world.save!

     # TREES
     batch_size = 100
     batch_count = -1
     world.resource_tiles.harvestable.find_in_batches(batch_size: batch_size) do |tiles|
       Stalker.enqueue('resource_tile.grow_tree_batch', resource_tile_ids: tiles.collect(&:id))
       batch_count += 1
     end

     bar = ProgressBar.new "Trees", batch_count
     log.info "Grow Trees"

     batch_count.times do |n|
       message = tree_complete_stalk.reserve
       message.delete

       log.info "trees: #{n}/#{batch_count}"
       bar.inc
     end
     bar.finish


     # HOUSING
     batch_size = 100
     batch_count = -1
     world.resource_tiles.find_in_batches(batch_size:batch_size) do |tiles|
       Stalker.enqueue('resource_tile.desirability_batch', resource_tile_ids: tiles.collect(&:id))
       batch_count += 1
     end

     bar = ProgressBar.new "Desirability", batch_count
     log.info "Desirability"
     batch_count.times do |n|
       message = desirability_complete_stalk.reserve
       message.delete

       log.info "desire: #{n}/#{batch_count}"
       bar.inc
     end
     bar.finish

     # PEOPLE
     bar = ProgressBar.new "Desirability", 1 
     log.info "People"
     turn_manager.migrate_people
     bar.finish

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
