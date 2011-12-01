module Tickers
  class LigerTicker < SpeciesTicker
    def self.tick(ct)
      ct.world.width.times do |x|
        ct.world.height.times do |y|
          #ligers breed like bunnies in mixed forest!
          if 1 == ct.deciduous[x,y]
            puts "\tLigers breeding at #{x}, #{y}"
            ### If this were for real, we might do something like the below ###
            # lt = LandTile.where(:world_id => ct.world.id, :x => x. :y => y)
            # lt.liger_density *= 1.25
            # lt.save!
          end
        end
      end
    end
  end
end
