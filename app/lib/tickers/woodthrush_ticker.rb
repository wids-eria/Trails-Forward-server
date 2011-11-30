require 'narray'
require 'matrix_utils'

class WoodthrushTicker < SpeciesTicker
  def self.tick(ct)

    result = compute_habitat ct.land
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


  #compute the habitat for woodthursh
  def self.compute_habitat(matrix)

  #WT=LF; %%%%%%%wood thursh has same properties as Flycather but bigger minimum size
  #WT=bwconncomp(WT,4);%%designate patches
  #wfstats=regionprops(WT,'Area'); %%calcualte size of patches
  #idWT = find([wfstats.Area] > 2);%%%%%%%%%%%%select patches greater than 2 acres needed as minimum core patch size
  #WT = ismember(labelmatrix(WT), idWT);%%%%%%%%%%%put those on a new matrix
  #WTsize=sum(WT);
  #WTsize=sum(WTsize);

    mx_lf = FlycatcherTicker.compute_habitat(matrix)
    mx_bwcc = bwcc_New(mx_lf.habitat)
    #mx_perim = bwperim(mx_decid_mixed)


    mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
    mx_habitat.fill!(0)
    count = 0

    mx_bwcc.PixelIdxList.each{ |val|
      #puts "length = #{val.length}\n"
      if(val.length>2 && mx_lf.habitat[val[0][0],val[0][1]]!=0)
        val.each{ |point|
          #puts "point #{point[0]}, #{point[1]}\n"
          count = count + 1
          mx_habitat[point[0],point[1]] = 1
        }
      end
    }

    #density 2.3p/10ha
    population = count * 0.404 * 2.3 / 10 * 2;
    #puts "Count = #{count}\n"
    output = HabitatOutput.new(count, population, mx_habitat)
    return output

  end

end
