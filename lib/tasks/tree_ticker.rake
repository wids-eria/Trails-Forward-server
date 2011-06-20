namespace :trails_forward do
  namespace :trees do
    
    desc "Tick the world's tree population forward by one year"
    task :tick_one_year, :world_id, :needs => [:environment] do |t, args|

    end
  end
end