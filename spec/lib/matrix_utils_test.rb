require 'matrix_utils'
require 'narray'

BirdOutput = Struct.new(:outputMatrix, :count)

class MatrixUtilsTest

  # tests the newer version of bwcc
  def test_New(testMatrix)
    MatrixUtils.bwcc_New(testMatrix)
  end

  # Tests the label matrix generator
  def test_Label(testMatrix)
    MatrixUtils.bwcc_Label(testMatrix)
  end

  # Tests the perimeter matrix generator
  def test_Perimeter(testMatrix)
    MatrixUtils.bwcc_Perimeter(testMatrix)
  end


  # Tests the bwperim matrix generator
  def test_bwperim(testMatrix)
    MatrixUtils.bwperim(testMatrix)
  end

  def test_Chickadee(testMatrix)
    tempOutput = MatrixUtils.bwcc_New(testMatrix)
    width = testMatrix.shape[0]
    height = testMatrix.shape[1]
    outputMatrix = NArray.byte(width,height)
    outputMatrix.fill!(0)
    count = 0

    tempOutput.PixelIdxList.each{ |val|
      if(val.length>5 && testMatrix[val[0][0],val[0][1]]!=0)
        val.each{ |point|
          outputMatrix[point[0],point[1]] = 1
          count = count + 1
        }
      end
    }

    BirdOutput.new(outputMatrix, count)
  end

  def test_Warbler(testMatrix)
    tempOutput = MatrixUtils.bwcc_New(testMatrix)
    perimOutput = MatrixUtils.bwcc_Perimeter(testMatrix)
    width = testMatrix.shape[0]
    height = testMatrix.shape[1]
    outputMatrix = NArray.byte(width,height)
    outputMatrix.fill!(0)
    count = 0

    tempOutput.PixelIdxList.each{ |val|
      if(val.length>0 && testMatrix[val[0][0],val[0][1]]!=0)
        val.each{ |point|
          if( perimOutput[point[0],point[1]] != 1)
            outputMatrix[point[0],point[1]] = 1
            count = count + 1
          end
        }
      end
    }

    BirdOutput.new(outputMatrix, count)
  end
end
