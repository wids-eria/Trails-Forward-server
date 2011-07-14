require 'narray'
require 'matrix_utils'
require 'ticker_utils'

class WoodthrushTicker < SpeciesTicker
  def self.tick(ct)
    
    result = compute_habitat_woodthursh ct.land
    puts "The count of resource tile with woodthursh habitat is #{result}"
  
=begin
    ct.world.width.times do |x|
      ct.world.height.times do |y|
        #ligers breed like bunnies in mixed forest!
        if 1 == result.habitat[x,y]
          puts "\tSpecies breeding at #{x}, #{y}"
          ### If this were for real, we might do something like the below ###
          # lt = LandTile.where(:world_id => ct.world.id, :x => x. :y => y)
          # lt.liger_density *= 1.25
          # lt.save!
        end
      end
    end
=end
    
  end
end
