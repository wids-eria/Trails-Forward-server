namespace :trails_forward do
  namespace :construction do  
    
    desc "Execute all pending construction in the world"
    task :execute_pending, :world_id, :needs => [:environment] do |t, args|
      #pass
    end
    
  end   
end