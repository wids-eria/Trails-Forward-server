require 'narray'

class CritterTicker
  
  attr_reader :deciduous, :coniferous, :mixed, :world
  
  SpeciesTickers = [LigerTicker]
  
  def initialize(world)
    @world = world
    get_species_data
  end
  
  def tick_all
    SpeciesTickers.each do |st|
      st.tick self
    end
  end  
  
  def get_species_data
    world_size = @world.width * @world.height
    
    deciduousness = 0
    @deciduous = NArray.byte(@world.width, @world.height)
    coniferousness = 0
    @coniferous = NArray.byte(@world.width, @world.height)
    mixedness = 0
    @mixed = NArray.byte(@world.width, @world.height)
    
    ResourceTile.where(:world_id => @world.id).find_in_batches do |group|
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
  end
    
end