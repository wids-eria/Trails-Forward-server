namespace :trails_forward do
  namespace :trades do

    desc "Execute all pending trades in the world"
    task :execute_pending, [:world_id] => [:environment] do |t, args|
      world = World.find args[:world_id]
      world.manager.execute_trades
    end     #task

  end
end
