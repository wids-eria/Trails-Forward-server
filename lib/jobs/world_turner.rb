require File.expand_path("../../../config/environment", __FILE__)
require 'stalker'
require_relative 'world_turn_jobs'

def turn_all_worlds
  World.ready_to_turn.all.each do |world|
    turn_a_world world
  end
end


def turn_a_world(world)
          tree_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :trees))
        marten_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :marten))
  desirability_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], pool_name(world.id, :desirability))

  turn_manager = WorldTurn.new world: world

  world.turn_state = 'processing'
  world.save!
  puts 'World state: processing'

   # TREES
   land_tile_count = world.resource_tiles.land_tiles.count
   world.resource_tiles.land_tiles.each do |tile|
     Stalker.enqueue('resource_tile.grow_trees', resource_tile_id: tile.id)
   end

   tree_bar = ProgressBar.new 'GrowTrees', land_tile_count
   land_tile_count.times do
     message = tree_complete_stalk.reserve
     tree_bar.inc
     message.delete
   end
  tree_bar.finish


   # MARTENS
   puts "martens"  
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
   resource_tile_count = world.resource_tiles.count
   world.resource_tiles.each do |tile|
     Stalker.enqueue('resource_tile.desirability', resource_tile_id: tile.id)
   end

   desire_bar = ProgressBar.new 'Desirability', resource_tile_count
   resource_tile_count.times do
     message = desirability_complete_stalk.reserve
     desire_bar.inc
     message.delete
   end
   desire_bar.finish

   # PEOPLE
   people_bar = ProgressBar.new 'People', 1
   turn_manager.migrate_people
   people_bar.finish

   # MONEY
   money_bar = ProgressBar.new 'Money', 1
   turn_manager.transfer_money
   money_bar.finish

   # END TURN
   turn_bar = ProgressBar.new 'Advance', 1
   turn_manager.advance_turn
   turn_bar.finish

   world.save!
end

turn_a_world(World.find(ARGV[0]))

