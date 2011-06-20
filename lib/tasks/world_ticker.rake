namespace :trails_forward do
  namespace :world do
    desc "Tick the world forward by one year"
    task(:tick_one_year, :world_id, :needs => [:environment]) do |t, args|
      world = World.find args[:world_id]
      Rake::Task['trails_forward:trades:execute_pending'].invoke(args[:world_id])
      Rake::Task['trails_forward:construction:execute_pending'].invoke(args[:world_id])
      Rake::Task['trails_forward:trees:tick_one_year'].invoke(args[:world_id])
      Rake::Task['trails_forward:birds:tick_one_year'].invoke(args[:world_id])
      world.year_current += 1
      world.save!
    end

    desc "Tick the world forward by four years"
    task(:tick_four_years, :world_id, :needs => [:environment]) do |t, args|
      world = World.find args[:world_id]
      Rake::Task['trails_forward:world:tick_one_year'].invoke(args[:world_id])
      3.times do
        Rake::Task['trails_forward:trees:tick_one_year'].reenable
        Rake::Task['trails_forward:trees:tick_one_year'].invoke(args[:world_id])

        Rake::Task['trails_forward:birds:tick_one_year'].reenable
        Rake::Task['trails_forward:birds:tick_one_year'].invoke(args[:world_id])
      end
      world.year_current += 3
      world.save!
    end
  end
end