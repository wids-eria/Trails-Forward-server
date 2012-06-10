require File.expand_path("../../../config/environment", __FILE__)
require 'stalker'
include Stalker


job 'world.migrate_population' do |args|
  world = World.find args["world_id"]
  world.migrate_population_to_most_desirable_tiles! args["population"].to_i
end
