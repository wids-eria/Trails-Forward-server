require 'narray'
require 'matrix_utils'
require 'ticker_utils'

namespace :trails_forward do
  namespace :birds do
    
    desc "Tick the world's bird population forward by one year"
    task :tick_all, :world_id, :needs => [:environment, :get_land_data] do |t, args|
      Rake::Task['trails_forward:birds:get_land_data'].invoke(args[:world_id])
      
      Rake::Task['trails_forward:birds:tick_chickadees'].invoke(args[:world_id])
      Rake::Task['trails_forward:birds:tick_cuckoo'].invoke(args[:world_id])
      Rake::Task['trails_forward:birds:tick_flycatchers'].invoke(args[:world_id])
      Rake::Task['trails_forward:birds:tick_warbler'].invoke(args[:world_id])
      Rake::Task['trails_forward:birds:tick_woodthursh'].invoke(args[:world_id])
      
    end
    
    
    desc "Tick species flycatchers forward by one year"
    task :tick_flycatchers, :world_id, :needs => [:environment, :get_land_data] do |cmd, args|
      Rake::Task['trails_forward:birds:get_land_data'].invoke(args[:world_id])
      puts "ticking flycatchers for #{@world.id}"
      result = compute_habitat_flycatchers @land
      #print_Matrix @land, @land.shape[0], @land.shape[1]
      puts "The count of resource tile with flycatchers habitat is #{result}"
    end
    
    
    desc "Tick species woodthursh forward by one year"
    task :tick_woodthursh, :world_id, :needs => [:environment, :get_land_data] do |cmd, args|
      Rake::Task['trails_forward:birds:get_land_data'].invoke(args[:world_id])
      puts "ticking woodthursh for #{@world.id}"
      result = compute_habitat_woodthursh @land
      #print_Matrix @land, @land.shape[0], @land.shape[1]
      puts "The count of resource tile with woodthursh habitat is #{result}"
    end
    
    
    desc "Tick species chickadees forward by one year"
    task :tick_chickadees, :world_id, :needs => [:environment, :get_land_data] do |cmd, args|
      Rake::Task['trails_forward:birds:get_land_data'].invoke(args[:world_id])
      puts "ticking chickadees for #{@world.id}"
      result = compute_habitat_chickadees @land
      #print_Matrix @land, @land.shape[0], @land.shape[1]
      puts "The count of resource tile with chickadees habitat is #{result}"
    end
    
    
    desc "Tick species warbler forward by one year"
    task :tick_warbler, :world_id, :needs => [:environment, :get_land_data] do |cmd, args|
      Rake::Task['trails_forward:birds:get_land_data'].invoke(args[:world_id])
      puts "ticking warbler for #{@world.id}"
      result = compute_habitat_warbler @land
      #print_Matrix @land, @land.shape[0], @land.shape[1]
      puts "The count of resource tile with warbler habitat is #{result}"
    end
    
    
    desc "Tick species cuckoo forward by one year"
    task :tick_cuckoo, :world_id, :needs => [:environment, :get_land_data] do |cmd, args|
      Rake::Task['trails_forward:birds:get_land_data'].invoke(args[:world_id])
      puts "ticking cuckoo for #{@world.id}"
      result = compute_habitat_cuckoo @land
      #print_Matrix @land, @land.shape[0], @land.shape[1]
      puts "The count of resource tile with cuckoo habitat is #{result}"
    end
    
    
    # desc "Retrieve land distribution data"
    task :get_land_data, :world_id, :needs => :environment do |t, args|
      world_id = args[:world_id]
      #puts "Getting land data for world #{world_id}..."
      @world = World.find world_id
      world_size = @world.width * @world.height
      
      @land = NArray.byte(@world.width, @world.height)
      @land.fill!(0)
      
      ResourceTile.where(:world_id => world_id).find_in_batches do |group|
        group.each do |rt|
          x = rt.x
          y = rt.y
          case rt.tree_species
            when ResourceTile::Verbiage[:tree_species][:deciduous]
              @land[x,y] = 1
            when ResourceTile::Verbiage[:tree_species][:coniferous]
              @land[x,y] = 2
            when ResourceTile::Verbiage[:tree_species][:mixed]
              @land[x,y] = 3
          end #case
        end #group
      end #find_in_batches
      
      
    end
    
    
    
    #desc "Tick species X forward by one year"
    task :tick_x, :world_id, :needs => [:environment, :get_species_data] do |cmd, args|
      Rake::Task['trails_forward:birds:get_species_data'].invoke(args[:world_id])
      puts "ticking x for #{@world.id}"
      #sayhello
    end
    
    # desc "Retrieve species distribution data"
    task :get_species_data, :world_id, :needs => :environment do |t, args|
      world_id = args[:world_id]
      puts "Getting species data for world #{world_id}..."
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
      puts "\t coniferousness = #{coniferousness.to_f / world_size}  deciduousness = #{deciduousness.to_f / world_size}  mixedness = #{mixedness.to_f / world_size}"
    end
    
  end
end

