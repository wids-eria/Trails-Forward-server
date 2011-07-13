require 'narray'
require 'matrix_utils'
require 'ticker_utils'

namespace :trails_forward do
  namespace :trees do
    
    desc "Tick the world's tree population forward by x year"
    task :tick_trees, :world_id, :years, :needs => [:environment, :get_tree_data] do |t, args|
      Rake::Task['trails_forward:trees:get_tree_data'].invoke(args[:world_id])
      puts "ticking trees for #{@world.id} for #{args[:years]} years"
      num_years = Integer(args[:years])
      result = compute_timber @decid, @conifer, @mixed, num_years
      
      puts "Old Tree Size"
      print_Matrix @old_tree_size, @old_tree_size.shape[0], @old_tree_size.shape[1]
      
      puts "New Tree Size"
      print_Matrix result.tree_size, result.tree_size.shape[0], result.tree_size.shape[0]
      
      #update the world
      world_id = args[:world_id]
      ResourceTile.where(:world_id => world_id).find_in_batches do |group|
        group.each do |rt|
          x = rt.x
          y = rt.y
          case rt.tree_species
            when ResourceTile::Verbiage[:tree_species][:deciduous]
              rt.tree_size = result.tree_size[x,y]
            when ResourceTile::Verbiage[:tree_species][:coniferous]
              rt.tree_size = result.tree_size[x,y]
            when ResourceTile::Verbiage[:tree_species][:mixed]
              rt.tree_size = result.tree_size[x,y]
          end #case
          rt.save!
        end #group
      end #find_in_batches
      
    end
    
    
    # desc "Retrieve tree distribution data"
    task :get_tree_data, :world_id, :needs => :environment do |t, args|
      world_id = args[:world_id]
      #puts "Getting tree data for world #{world_id}..."
      @world = World.find world_id
      world_size = @world.width * @world.height
      
      @old_tree_size = NArray.byte(@world.width, @world.height)
      @decid = NArray.byte(@world.width, @world.height)
      @conifer = NArray.byte(@world.width, @world.height)
      @mixed = NArray.byte(@world.width, @world.height)
      @old_tree_size.fill!(0)
      @decid.fill!(0)
      @conifer.fill!(0)
      @mixed.fill!(0)
      
      ResourceTile.where(:world_id => world_id).find_in_batches do |group|
        group.each do |rt|
          x = rt.x
          y = rt.y
          case rt.tree_species
            when ResourceTile::Verbiage[:tree_species][:deciduous]
              @decid[x,y] = rt.tree_size
              @old_tree_size[x,y] = rt.tree_size
            when ResourceTile::Verbiage[:tree_species][:coniferous]
              @conifer[x,y] = rt.tree_size
              @old_tree_size[x,y] = rt.tree_size
            when ResourceTile::Verbiage[:tree_species][:mixed]
              @mixed[x,y] = rt.tree_size
              @old_tree_size[x,y] = rt.tree_size
          end #case
        end #group
      end #find_in_batches
    end
    
    
    
  end
end

