require 'narray'


#Bwconncomp old version
#Takes matrtix as input
#Returns label matrix with uniquely labeled regions 

def bwcc (mainMatrix)
  
  width = mainMatrix.shape[0]
  height = mainMatrix.shape[1]
  
  nextLabel = 0
  linked = []
  typeMatrix = NArray.byte(width,height)
  #First pass
    for y in (0...(height))
       for x in (0...(width))
            neighbors = []
            neighborLabels = []
            
            if(x>0 && y>0 && mainMatrix[(x-1),y]==mainMatrix[x,y] && mainMatrix[x,(y-1)]==mainMatrix[x,y]&&typeMatrix[(x-1),y]!=typeMatrix[x,(y-1)])
              linked[typeMatrix[(x-1),y]]=linked[typeMatrix[(x-1),y]]|linked[typeMatrix[x,(y-1)]]
              linked[typeMatrix[x,(y-1)]]=linked[typeMatrix[x,(y-1)]]|linked[typeMatrix[(x-1),y]]
              typeMatrix[x,y] =[typeMatrix[(x-1),y],typeMatrix[x,(y-1)]].min
            elsif(x>0 && mainMatrix[(x-1),y]==mainMatrix[x,y])
              typeMatrix[x,y] = typeMatrix[(x-1),y]
            elsif(y>0 && mainMatrix[x,(y-1)]==mainMatrix[x,y])
              typeMatrix[x,y] = typeMatrix[x,(y-1)]
            else
              linked[nextLabel] = [nextLabel]  
              typeMatrix[x,y] = nextLabel
              nextLabel = nextLabel + 1
            end
          
        end
      end
      
    #Second pass
   for y in (0...(height))
      for x in (0...(width))
        temp = []
        temp = linked[typeMatrix[x,y]]
        typeMatrix[x,y] = temp.min
      end
    end

    return typeMatrix
end


#Takes matrtix as input
#Returns matrix with 1's on every area that is a region boundary, 0 everywhere else 
#NOTE: Edges of the matrix are considered boundaries
def bwcc_Perimeter (mainMatrix) 
  
  width = mainMatrix.shape[0]
  height = mainMatrix.shape[1]
  
  perimMatrix = NArray.byte(width,height)
  perimMatrix.fill!(0)
  #First pass
    for y in (0...(height))
       for x in (0...(width))
            if((x>0 && mainMatrix[(x-1),y]!=mainMatrix[x,y]) ||
              (y>0 && mainMatrix[x,(y-1)]!=mainMatrix[x,y]) ||
              (x<(width-1) && mainMatrix[(x+1),y]!=mainMatrix[x,y]) ||
              (y<(height-1) && mainMatrix[x,(y+1)]!=mainMatrix[x,y]))
              perimMatrix[x,y] = 1
            end
          
        end
      end
    return perimMatrix
end


#Takes matrix as input
#'puts' each line of matrix into console for easy reading
def print_Matrix(matrix,width,height)
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

#Bwconncomp new version
#Takes matrtix as input
#Returns output which has members ImageSize, NumObjects, PixelIdxList
#They function the same as matlab's bwconncomp
def bwcc_New (mainMatrix)
  newMatrix = bwcc(mainMatrix)
  #Go through once inserting into hash table so duplicates automatically overwrite. The end hash table will have N items where N is the number of different regions
  width = newMatrix.shape[0]
  height = newMatrix.shape[1]
  uniqueHTable = Hash.new()
  
  #First pass
  for y in (0...(height))
    for x in (0...(width))
      if(!uniqueHTable[newMatrix[x,y]])
         uniqueHTable[newMatrix[x,y]] = Array.new 
      end
      uniqueHTable[newMatrix[x,y]].push([x,y])
    end
  end
  
  pIDList =  Array.new
  uniqueHTable.each_key{ |key|
    pIDList.push(uniqueHTable[key])
  }   
  output = Output.new(newMatrix.shape, uniqueHTable.length, pIDList)
  return output
end


#takes matrix as input and generates a label matrix with minium values  
def bwcc_Label (mainMatrix)
  newMatrix = bwcc(mainMatrix)
  #Go through once inserting into hash table so duplicates automatically overwrite. The end hash table will have N items where N is the number of different regions
  width = newMatrix.shape[0]
  height = newMatrix.shape[1]
  uniqueHTable = Hash.new()
  
  newIndex = 0
  #First pass
  for y in (0...(height))
    for x in (0...(width))
      if(!uniqueHTable[newMatrix[x,y]])
         uniqueHTable[newMatrix[x,y]] = newIndex
         newIndex = newIndex + 1 
      end
    end
  end
  
  #Replacement pass
  for y in (0...(height))
    for x in (0...(width))
      newMatrix[x,y] = uniqueHTable[newMatrix[x,y]]
    end
  end
  
  return newMatrix
end