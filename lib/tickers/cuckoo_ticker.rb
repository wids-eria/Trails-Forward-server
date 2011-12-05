require 'narray'
require 'matrix_utils'

module Tickers
  class CuckooTicker < SpeciesTicker
    def self.tick(ct)
      result = compute_habitat ct.land
      puts "The count of resource tile with cuckoo habitat is #{result}"

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

    # compute the habitat for black-billed cuckoo
    def self.compute_habitat(matrix)

      # BBC=(decid+conifer+mixed); %%%Make landscape that is not water
      # BBC=bwconncomp(BBC,4);%%%%%%%find edge of this landscape
      # bbcstats=regionprops(BBC,'Area');%%%find the area
      # idBBC=find([bbcstats.Area]>1);%%%see if area exist
      # BBC2=ismember(labelmatrix(BBC),idBBC);%%%label matrix of BBC2
      # BBC=bwperim(BBC2);%%find paramters
      # BBC3=(decid+mixed);%%%%make landscape of just suitable habitat
      # BBC=BBC3==1&BBC==1; %%%%%%suitable habitat + Parameter
      # BBCsize=sum(BBC);
      # BBCsize=sum(BBCsize,2);  %%%%%%%%%%%amount of habitat for BBCrequire 'matrix_utils'

      mx_decid = matrix.eq(1)
      mx_conifer = matrix.eq(2)
      mx_mixed = matrix.eq(3)

      mx_trees = mx_decid + mx_conifer + mx_mixed
      mx_decid_mixed = mx_decid + mx_mixed


      mx_bwcc = MatrixUtils.bwcc_New(mx_trees)
      mx_perim = MatrixUtils.bwperim(mx_trees)


      mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
      mx_habitat.fill!(0)
      count = 0


      # print_Matrix perim, 5, 5
      # puts "--------------\n"

      mx_bwcc.PixelIdxList.each{ |val|
        # puts "length = #{val.length}\n"
        if(val.length>1 && mx_trees[val[0][0],val[0][1]]!=0)
          val.each{ |point|
            # puts "point #{point[0]}, #{point[1]}\n"
            if(mx_perim[point[0],point[1]]!=0 && mx_decid_mixed[point[0],point[1]]!=0)
              count = count + 1
              mx_habitat[point[0],point[1]] = 1
            end
          }
        end
      }

      # density 0.25 p/10 ha
      population = count * 0.404 * 0.25 / 10 * 2;
      # puts "Count = #{count}\n"
      HabitatOutput.new(count, population, mx_habitat)
    end
  end
end
