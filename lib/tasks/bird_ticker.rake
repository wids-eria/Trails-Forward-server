require 'narray'
require 'matrix_utils'

namespace :trails_forward do
  namespace :birds do
    
    desc "Tick the world's bird population forward by one year"
    task :tick_one_year, :world_id, :needs => [:environment] do |t, args|
      Rake::Task['trails_forward:birds:get_species_data'].invoke(args[:world_id])
      Rake::Task['trails_forward:birds:tick_x'].invoke(args[:world_id])
    end
    
    desc "Tick species X forward by one year"
    task :tick_x, :world_id, :needs => [:environment, :get_species_data] do |cmd, args|
      Rake::Task['trails_forward:birds:get_species_data'].invoke(args[:world_id])
    end
    
    # desc "Retrieve species distribution data"
    task :get_species_data, :world_id, :needs => :environment do |t, args|
      world_id = args[:world_id]
      puts "Getting tree species data for world #{world_id}..."
      @world = World.find world_id
      world_size = @world.width * @world.height
      
      deciduousness = 0
      @deciduous = NArray.byte(@world.width, @world.height)
      coniferousness = 0
      @coniferous = NArray.byte(@world.width, @world.height)
      mixedness = 0
      @mixed = NArray.byte(@world.width, @world.height)
      
      ResourceTile.where(:world_id => world_id).find_in_batches do |group|
        group.each do |rt|
          x = rt.x
          y = rt.y
          case rt.tree_species
            when ResourceTile::Verbiage[:tree_species][:coniferous]
              coniferousness += 1
              @coniferous[x,y] = 1
            when ResourceTile::Verbiage[:tree_species][:deciduous]
              deciduousness += 1
              @deciduous[x,y] = 1
            when ResourceTile::Verbiage[:tree_species][:mixed]
              mixedness += 1
              @mixed[x,y] = 1
          end #case
        end #group
      end #find_in_batches
      puts "\t coniferousness = #{coniferousness.to_f / world_size} \n\t deciduousness = #{deciduousness.to_f / world_size} \n\t mixedness = #{mixedness.to_f / world_size}"
    end
    
  end
end

