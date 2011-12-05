require 'narray'
require 'matrix_utils'

module Tickers
  class WarblerTicker < SpeciesTicker
    def self.tick(ct)
      result = compute_habitat ct.land
      puts "The count of resource tile with warbler habitat is #{result}"

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


    # compute the habitat for warbler
    def self.compute_habitat(matrix)

      # CW=conifer+mixed;%%%%%%%%%CW uses mixed and conifer
      # CW=bwconncomp(CW,4);%%%%%%%%%%Designate patches
      # cwstats=regionprops(CW,'Area'); %%calcualte size of patches
      # idCW = find([cwstats.Area] > 0);%%%%%%%%%%%%select patches greater than a given size
      # CW2 = ismember(labelmatrix(CW), idCW);%%%%%%%%%%%put those on a new matrix
      # PCW2=bwperim(CW2);%%%%%%%%%%%%%%Take off parameters
      # CW= PCW2==0 & CW2==1;%%%%Core area for Warbler
      # CWsize=sum(CW);
      # CWsize=sum(CWsize); %%%%%%Amount of Warbler forest

      mx_conifer = matrix.eq(2)
      mx_mixed = matrix.eq(3)

      mx_conifer_mixed = mx_conifer + mx_mixed

      mx_bwcc = MatrixUtils.bwcc_New(mx_conifer_mixed)
      mx_perim = MatrixUtils.bwperim(mx_conifer_mixed)

      mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
      mx_habitat.fill!(0)
      count = 0


      mx_bwcc.PixelIdxList.each{ |val|
        # puts "length = #{val.length}\n"
        if(val.length>0 && mx_conifer_mixed[val[0][0],val[0][1]]!=0)
          val.each{ |point|
            # puts "point #{point[0]}, #{point[1]}\n"
            if(mx_perim[point[0],point[1]]==0)
              count = count + 1
              mx_habitat[point[0],point[1]] = 1
            end
          }
        end
      }

      # density 1 pair/10 ha
      population = count * 0.404 * 1 / 10 * 2;
      HabitatOutput.new(count, population, mx_habitat)
    end
  end
end
