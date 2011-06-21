namespace :trails_forward do
  namespace :world do
    desc "Tick the world forward by one year"
    task(:tick_one_year, :world_id, :needs => [:environment]) do |t, args|
      world = World.find args[:world_id]
      world.manager.tick_world
    end


    desc "Tick the world forward by four years"
    task(:tick_four_years, :world_id, :needs => [:environment]) do |t, args|
      world = World.find args[:world_id]
      world.manager.tick_world 4
    end

  end
end