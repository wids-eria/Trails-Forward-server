require 'narray'

class CritterTicker
  
  attr_reader :land, :world
  
  SpeciesTickers = [ChickadeeTicker, CuckooTicker, FlycatcherTicker, WarblerTicker, WoodthrushTicker]
  
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
  
    @land = NArray.byte(@world.width, @world.height)
    @land.fill!(0)
    
    ResourceTile.where(:world_id => @world.id).find_in_batches do |group|
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
    
end
