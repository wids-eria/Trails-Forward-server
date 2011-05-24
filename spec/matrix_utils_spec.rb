require 'spec_helper'
require 'matrix_utils_test'

RSpec::Matchers.define :equalMatrix do |goal|
  match do |target|
    target.eq(goal).all?
  end
end

describe Matrix_utils_test, "#outputMatrix" do
  it "returns appropriate result for uniform matrix" do
    matrix_utils_test = Matrix_utils_test.new
    testMatrix = NArray.byte(5,5)
    testMatrix.fill!(4)
    goalMatrix = NArray.byte(5,5)
    goalMatrix.fill!(0)
    matrix_utils_test.test(testMatrix).should equalMatrix(goalMatrix)
  end
  
  it "exists within reailty" do
    1.should == 1
  end
  
  it "returns appropriate result for checkerboard martrix" do
      matrix_utils_test = Matrix_utils_test.new
      testMatrix = NArray[[1,2,1,2,1],[2,1,2,1,2],[1,2,1,2,1],[2,1,2,1,2],[1,2,1,2,1]] 
      goalMatrix = NArray[[0,1,2,3,4],[5,6,7,8,9],[10,11,12,13,14],[15,16,17,18,19],[20,21,22,23,24]]
      matrix_utils_test.test(testMatrix).should equalMatrix(goalMatrix)
  end
    
  it "returns appropriate result for asymetric striped martrix" do
      matrix_utils_test = Matrix_utils_test.new
      testMatrix = NArray[[1,2,3,2],[1,2,3,2],[1,2,3,2],[1,2,3,2],[1,2,3,2],[1,2,3,2],[1,2,3,2]] 
      goalMatrix = NArray[[0,1,2,3],[0,1,2,3],[0,1,2,3],[0,1,2,3],[0,1,2,3],[0,1,2,3],[0,1,2,3]]
      matrix_utils_test.test(testMatrix).should equalMatrix(goalMatrix)
  end
  
  it "returns appropriate result for 3 region swirl matrix" do
      matrix_utils_test = Matrix_utils_test.new
      testMatrix = NArray[[111,111,111,111,111],[4,4,4,4,111],[111,111,111,4,111],[111,4,4,4,111],[111,4,111,4,111],[111,4,4,4,111],[111,111,111,111,111]] 
      goalMatrix = NArray[[0,0,0,0,0],[1,1,1,1,0],[0,0,0,1,0],[0,1,1,1,0],[0,1,4,1,0],[0,1,1,1,0],[0,0,0,0,0]] 
      matrix_utils_test.test(testMatrix).should equalMatrix(goalMatrix)
  end
  
  
  it "returns appropriate result for 5x5 divided by diagonal" do
      matrix_utils_test = Matrix_utils_test.new
      testMatrix = NArray[[7,4,4,4,4],[4,7,4,4,4],[4,4,7,4,4],[4,4,4,7,4],[4,4,4,4,7]] 
      goalMatrix = NArray[[0,1,1,1,1],[2,3,1,1,1],[2,2,4,1,1],[2,2,2,5,1],[2,2,2,2,6]] 
      matrix_utils_test.test(testMatrix).should equalMatrix(goalMatrix)
  end
  
  it "returns appropriate result for 5x5 divided by diagonal perimeter matrix" do
      matrix_utils_test = Matrix_utils_test.new
      testMatrix = NArray[[7,4,4,4,4],[4,7,4,4,4],[4,4,7,4,4],[4,4,4,7,4],[4,4,4,4,7]] 
      goalMatrix = NArray[[1,1,0,0,0],[1,1,1,0,0],[0,1,1,1,0],[0,0,1,1,1],[0,0,0,1,1]] 
      matrix_utils_test.test_Perimeter(testMatrix).should equalMatrix(goalMatrix)
  end
  
  it "returns approrpiate result for andvanced test output" do
    matrix_utils_test = Matrix_utils_test.new
    testMatrix = NArray[[1,1,1],[1,1,2],[2,2,2]] 
    goalMatrix = [ [[0,0],[1,0],[2,0],[0,1],[1,1]] , [[2,1],[0,2],[1,2],[2,2]] ] 
    sizeGoal = [3,3]
    matrix_utils_test.test_New(testMatrix).PixelIdxList.should == goalMatrix    
    matrix_utils_test.test_New(testMatrix).ImageSize.should == sizeGoal    
    matrix_utils_test.test_New(testMatrix).NumObjects.should == 2    
  end
  
  it "returns appropriate result for 3 region swirl matrix with lowest labels" do
       matrix_utils_test = Matrix_utils_test.new
       testMatrix = NArray[[111,111,111,111,111],[4,4,4,4,111],[111,111,111,4,111],[111,4,4,4,111],[111,4,111,4,111],[111,4,4,4,111],[111,111,111,111,111]] 
       goalMatrix = NArray[[0,0,0,0,0],[1,1,1,1,0],[0,0,0,1,0],[0,1,1,1,0],[0,1,2,1,0],[0,1,1,1,0],[0,0,0,0,0]] 
       matrix_utils_test.test_Label(testMatrix).should equalMatrix(goalMatrix)
   end
   

   it "Passes the dreaded Chickadeee test" do
    matrix_utils_test = Matrix_utils_test.new
    testMatrix = NArray[ [0,0,0,1,1,1], [1,1,0,0,0,1], [1,1,0,0,1,1], [0,0,1,0,0,1], [0,1,1,0,0,0], [1,1,1,1,1,0], [1,1,1,1,0,0] ] 
    goalMatrix = NArray[ [0,0,0,1,1,1], [0,0,0,0,0,1], [0,0,0,0,1,1], [0,0,1,0,0,1], [0,1,1,0,0,0], [1,1,1,1,1,0], [1,1,1,1,0,0] ]  
    matrix_utils_test.test_Chickadee(testMatrix).outputMatrix.should equalMatrix(goalMatrix)
    matrix_utils_test.test_Chickadee(testMatrix).count.should == 19
   end
   
   it "Passes the warbler test with perimeters" do
     matrix_utils_test = Matrix_utils_test.new
     testMatrix = NArray[ [0,0,0,1,1,1], [1,1,0,0,0,1], [1,1,0,0,1,1], [0,0,1,0,0,1], [0,1,1,0,0,0], [1,1,1,1,1,0], [1,1,1,1,0,0] ] 
     goalMatrix = NArray[ [0,0,0,0,0,1], [0,0,0,0,0,0], [0,0,0,0,0,1], [0,0,0,0,0,0], [0,0,0,0,0,0], [0,1,1,0,0,0], [1,1,1,0,0,0] ]  
     matrix_utils_test.test_Warbler(testMatrix).outputMatrix.should equalMatrix(goalMatrix)
     matrix_utils_test.test_Warbler(testMatrix).count.should == 7
   end
   
  
end
