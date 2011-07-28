require 'narray'
require 'matrix_utils'

class FlycatcherTicker < SpeciesTicker
  def self.tick(ct)
    
    result = compute_habitat ct.land
    puts "The count of resource tile with flycatchers habitat is #{result}"
  
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
  
  #compute the habitat for flycatchers
  def self.compute_habitat(matrix)

  #LF=(decid+mixed); %%%flycatchers can live in decid and mixed forest
  #LF=bwconncomp(LF,4);%%%%%%%%%%Designate patches
  #lfstats=regionprops(LF,'Area'); %%calcualte size of patches
  #idLF = find([lfstats.Area] > 0);%%%%%%%%%%%%select patches greater than a given size
  #LF2 = ismember(labelmatrix(LF), idLF);%%%%%%%%%%%put those on a new matrix
  #PLF2=bwperim(LF2);%%%%%%%%%%%%%%Take off parameters 
  #LF= PLF2==0 & LF2==1;%%%%Core area for Flycatcher
  #LFsize=sum(LF);
  #LFsize=sum(LFsize); %%%%%%Amount of flycatcher forest
    
    mx_decid = matrix.eq(1)
    mx_mixed = matrix.eq(3)

    mx_decid_mixed = mx_decid + mx_mixed

    mx_bwcc = bwcc_New(mx_decid_mixed)
    mx_perim = bwperim(mx_decid_mixed)
    
    mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
    mx_habitat.fill!(0)
    count = 0
      
    mx_bwcc.PixelIdxList.each{ |val|
      #puts "length = #{val.length}\n"
      if(val.length>0 && mx_decid_mixed[val[0][0],val[0][1]]!=0)
        val.each{ |point|
          #puts "point #{point[0]}, #{point[1]}\n"
          if(mx_perim[point[0],point[1]]==0)
            count = count + 1
            mx_habitat[point[0],point[1]] = 1
          end
        }
      end
    }
    
    
    #density 15p/10ha
    population = count * 0.404 * 15 / 10 * 2;
    #puts "Count = #{count}\n"
    output = HabitatOutput.new(count, population, mx_habitat)
    return output

  end


end
