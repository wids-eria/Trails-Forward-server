# require 'narray'

module Tickers
  class CritterTicker

#     attr_reader :land, :world

#     Tickers::SpeciesTickers = [Tickers::ChickadeeTicker, Tickers::CuckooTicker, Tickers::FlycatcherTicker, Tickers::WarblerTicker, Tickers::WoodthrushTicker]

#     def initialize(world)
#       @world = world
#       get_species_data
#     end

#     def tick_all
#       Tickers::SpeciesTickers.each do |st|
#         st.tick self
#       end
#     end

#     def get_species_data

#       @land = NArray.byte(@world.width, @world.height)
#       @land.fill!(0)

#       ResourceTile.where(:world_id => @world.id).find_in_batches do |group|
#         group.each do |rt|
#           x = rt.x
#           y = rt.y
#           case rt.land_cover_type
#           when ResourceTile.verbiage[:land_cover_type][:deciduous]
#             @land[x,y] = 1
#           when ResourceTile.verbiage[:land_cover_type][:coniferous]
#             @land[x,y] = 2
#           when ResourceTile.verbiage[:land_cover_type][:mixed]
#             @land[x,y] = 3
#           end
#         end
#       end

#     end

  end
end
