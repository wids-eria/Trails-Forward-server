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

  turn_manager = WorldTurn.new world

  # TREES
   puts "growing trees"
   world.resource_tiles.land_tiles.each do |tile|
     Stalker.enqueue('resource_tile.grow_trees', resource_tile_id: tile.id)
   end

   world.resource_tiles.land_tiles.count.times do
     message = tree_complete_stalk.reserve
     print "."
     message.delete
   end


   # MARTENS
   puts "martens"
   world.resource_tiles.land_tiles.each do |tile|
     Stalker.enqueue('resource_tile.marten_suitability', resource_tile_id: tile.id)
   end

   world.resource_tiles.land_tiles.count.times do
     message = marten_complete_stalk.reserve
     print "."
     message.delete
   end

   world.update_marten_suitable_tile_count

   # HOUSING
   puts "desire"
   world.resource_tiles.each do |tile|
     Stalker.enqueue('resource_tile.update_total_desirability', resource_tile_id: tile.id)
   end

   world.resource_tiles.count.times do
     message = desire_complete_stalk.reserve
     print "."
     message.delete
   end

   # PEOPLE
   turn.migrate_people

   # MONEY
   turn.transfer_money

   # END TURN
   turn.advance_turn

   world.save!
end

turn_a_world(World.find(10))

