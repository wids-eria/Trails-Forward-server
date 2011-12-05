require 'narray'
require 'matrix_utils'

namespace :trails_forward do
  namespace :critters do

    desc "Tick the world's critter population forward by one year"
    task :tick_one_year, [:world_id] => [:environment] do |t, args|
      world = World.find args[:world_id]
      world.manager.tick_critters
    end

  end
end
