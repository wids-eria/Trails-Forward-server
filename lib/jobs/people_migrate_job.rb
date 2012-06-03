require File.expand_path("../../../config/environment", __FILE__)
require 'stalker'
include Stalker


def migrate_population(world, population)
  #zero out occupancy
  ResourceTile.connection.execute("UPDATE resource_tiles SET housing_occupants = 0 WHERE world_id=#{world.id}")
  
  #stick people in the best places first, and prefer less populated over more populated 
  places_with_people = []
  
  #Can't do the following because order is ignored by find_in_batches
  #    world.resource_tiles.most_desirable.where('housing_capacity > 0').find_in_batches do |group|
  batch_size = 1000
  ((world.width * world.height)/batch_size).to_i.times do |page|
    group = world.resource_tiles.most_desirable.paginate(:page => page + 1, :per_page => batch_size).to_a
    best_places = group.sort {|x, y| x.housing_capacity <=> y.housing_capacity }
    best_places.each do |rt|
      rt.housing_occupants = rt.housing_capacity
      population -= rt.housing_capacity
      places_with_people << rt
      rt.save!
      break if population <= 0
    end 
    break if population <= 0
  end 


  #TODO: give rent to owners of occupied land.
  puts "#{places_with_people.count} tiles are now occupied"
end

job 'world.migrate_population' do |args|
  world = World.find args["world_id"]
  migrate_population world, args["population"].to_i
end
