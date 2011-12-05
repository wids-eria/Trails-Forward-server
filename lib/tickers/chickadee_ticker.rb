require 'narray'
require 'matrix_utils'

module Tickers
  class ChickadeeTicker < SpeciesTicker
    def self.tick(ct)
      result = compute_habitat ct.land
      puts "The count of resource tile with chickadee habitat is #{result}"
    end

    # compute the habitat for chickadees
    def self.compute_habitat(matrix)

      # C=bwconncomp(Conifer,4);%%%%%%create patches for Conifer
      # cstats=regionprops(C,'Area');%%%%%Measure of patch area conifer
      # idC = find([cstats.Area] > 5);%%%%%%%%%%%%select patches greater than 5 acres
      # C2 = ismember(labelmatrix(C), idC);%%%%%%%%%%%put those on a new matrix
      # BC=C2;
      # BCsize=sum(C2);
      # BCsize=sum(BCsize); %%% Amout of land with Chickadees on it

      mx_conifer = matrix.eq(2)
      mx_bwcc = MatrixUtils.bwcc_New(mx_conifer)

      mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
      mx_habitat.fill!(0)
      count = 0

      mx_bwcc.PixelIdxList.each{ |val|
        # puts "length = #{val.length}\n"
        if(val.length>5 && mx_conifer[val[0][0],val[0][1]]!=0)
          val.each{ |point|
            # puts "point #{point[0]}, #{point[1]}\n"
            count = count + 1
            mx_habitat[point[0],point[1]] = 1
          }
        end
      }

      # density 0.4 p/10 ha
      population = count * 0.404 * 0.4 / 10 * 2;
      # puts "Count = #{count}\n"
      HabitatOutput.new(count, population, mx_habitat)
    end
  end
end
