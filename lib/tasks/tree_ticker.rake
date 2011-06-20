namespace :trails_forward do
  namespace :trees do
    
    desc "Tick the world's tree population forward by one year"
    task :tick_one_year, :world_id, :needs => [:environment] do |t, args|
      world = World.find args[:world_id]
      world.lock!
      ActiveRecord::Base.transaction do
        ResourceTile.where(:world_id => world.id).find_in_batches do |group|
          group.each do |rt|
            rt.grow_trees
            rt.save!
          end
        end
      end #transaction
    end #task

  end
end