namespace :trails_forward do
  namespace :trees do

    desc "Tick the world's tree population forward by one year"
    task :tick_one_year, [:world_id] => [:environment] do |t, args|
      world = World.find args[:world_id]
      world.manager.tick_trees
    end #task

  end
end
