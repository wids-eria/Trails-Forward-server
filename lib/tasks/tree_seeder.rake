require 'initialize_trees'

namespace :trails_forward do
  namespace :trees do    
    desc "Randomly generate trees based upon FIA distributions"
    task :seed_trees, :world_id, :needs => [:environment] do |t, args|
      world = World.find args[:world_id]
      seed_trees(world)
    end
  end
end