require 'narray'

module MatrixUtils
  # Returns label matrix with uniquely labeled regions
  def self.connected_component_regions(main_matrix)
    width = main_matrix.shape[0]
    height = main_matrix.shape[1]

    next_label = 0
    linked = []
    type_matrix = NArray.byte(width,height)

    # First pass
    (0...height).each do |y|
      (0...width).each do |x|
        here = main_matrix[x, y]
        west = main_matrix[x-1, y]
        north = main_matrix[x, y-1]
        here_type = type_matrix[x, y]
        west_type = type_matrix[x-1, y]
        north_type = type_matrix[x, y-1]

        if x > 0 && y > 0 && here == west && here == north && west_type != north_type
          group = linked[west_type] | linked[north_type]
          linked[west_type] = group
          linked[north_type] = group
          type_matrix[x, y] = [west_type, north_type].min
        elsif x > 0 && here == west
          type_matrix[x, y] = west_type
        elsif y > 0 && here == north
          type_matrix[x, y] = north_type
        else
          linked[next_label] = [next_label]
          type_matrix[x, y] = next_label
          next_label += 1
        end

      end
    end

    # Second pass
    (0...height).each do |y|
      (0...width).each do |x|
        type_matrix[x,y] = linked[type_matrix[x, y]].min
      end
    end

    type_matrix
  end


  # Takes matrix as input
  # Returns matrix with 1's on every area that is a region boundary, 0 everywhere else
  # NOTE: Edges of the matrix are considered boundaries
  def self.bwcc_Perimeter (main_matrix)

    width = main_matrix.shape[0]
    height = main_matrix.shape[1]

    perim_matrix = NArray.byte(width,height)
    perim_matrix.fill!(0)
    # First pass
    for y in (0...(height))
      for x in (0...(width))
        if((x>0 && main_matrix[(x-1),y]!=main_matrix[x,y]) ||
           (y>0 && main_matrix[x,(y-1)]!=main_matrix[x,y]) ||
           (x<(width-1) && main_matrix[(x+1),y]!=main_matrix[x,y]) ||
           (y<(height-1) && main_matrix[x,(y+1)]!=main_matrix[x,y]))
          perim_matrix[x,y] = 1
        end

      end
    end
    return perim_matrix
  end


  # Takes matrtix as input
  # Returns matrix with 1's only on the perimeter, 0 everywhere else
  # NOTE: Edges of the matrix are considered boundaries
  def self.bwperim (main_matrix)

    width = main_matrix.shape[0]
    height = main_matrix.shape[1]
    perim_matrix = NArray.byte(width,height)
    perim_matrix.fill!(0)

    for y in (0...(height))
      for x in (0...(width))
        if(main_matrix[x,y]!=0)
          perim_matrix[x,y] = 1
        else
          perim_matrix[x,y] = 0
        end
      end
    end



    for y in (0...(height))
      for x in (0...(width))

        if((x>0 && main_matrix[(x-1),y]!=0) &&
           (y>0 && main_matrix[x,(y-1)]!=0) &&
           (x<(width-1) && main_matrix[(x+1),y]!=0) &&
           (y<(height-1) && main_matrix[x,(y+1)]!=0))
          perim_matrix[x,y] = 0
        end

      end
    end

    return perim_matrix
  end



  # Takes matrix as input
  # 'puts' each line of matrix into console for easy reading
  def self.print__matrix(matrix,width,height)
    for y in (0...(height))
      str = ""
      for x in (0...(width))
        str += matrix[x,y].to_s()
        str += '-'
      end
      puts str
    end
  end



  Output = Struct.new(:ImageSize, :NumObjects, :PixelIdxList)

  # Bwconncomp new version
  # Takes matrtix as input
  # Returns output which has members ImageSize, NumObjects, PixelIdxList
  # They function the same as matlab's bwconncomp
  def self.bwcc_New (main_matrix)
    new_matrix = connected_component_regions(main_matrix)
    # Go through once inserting into hash table so duplicates automatically overwrite. The end hash table will have N items where N is the number of different regions
    width = new_matrix.shape[0]
    height = new_matrix.shape[1]
    unique_hash_table = Hash.new()

    # First pass
    for y in (0...(height))
      for x in (0...(width))
        if(!unique_hash_table[new_matrix[x,y]])
          unique_hash_table[new_matrix[x,y]] = Array.new
        end
        unique_hash_table[new_matrix[x,y]].push([x,y])
      end
    end

    id_list =  Array.new
    unique_hash_table.each_key{ |key|
      id_list.push(unique_hash_table[key])
    }
    output = Output.new(new_matrix.shape, unique_hash_table.length, id_list)
    return output
  end


  # takes matrix as input and generates a label matrix with minium values
  def self.bwcc_Label (main_matrix)
    new_matrix = connected_component_regions(main_matrix)
    # Go through once inserting into hash table so duplicates automatically overwrite. The end hash table will have N items where N is the number of different regions
    width = new_matrix.shape[0]
    height = new_matrix.shape[1]
    unique_hash_table = Hash.new()

    newIndex = 0
    # First pass
    for y in (0...(height))
      for x in (0...(width))
        if(!unique_hash_table[new_matrix[x,y]])
          unique_hash_table[new_matrix[x,y]] = newIndex
          newIndex = newIndex + 1
        end
      end
    end

    # Replacement pass
    for y in (0...(height))
      for x in (0...(width))
        new_matrix[x,y] = unique_hash_table[new_matrix[x,y]]
      end
    end

    return new_matrix
  end
end
