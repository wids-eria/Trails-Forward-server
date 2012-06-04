require File.expand_path("../../../config/environment", __FILE__)
require 'stalker'
include Stalker


def migrate_population(world, population)
  world.migrate_population_to_most_desirable_tiles! population
end

job 'world.migrate_population' do |args|
  world = World.find args["world_id"]
  migrate_population world, args["population"].to_i
end
