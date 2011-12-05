require 'spec_helper'
require 'tickers'

RSpec::Matchers.define :approxEqualMatrix do |goal|
  match do |target|
    diff = target - goal
    # print_Matrix diff.abs, 5, 5
    diff.abs.lt(0.1).all?
    # diff.lt(Float::EPSILON).all?
  end
end

describe do
  it "test cuckoo" do
    testMatrix = NArray[[1,2,3,4,1],[1,2,3,4,1],[1,2,3,4,1],[1,2,3,4,1],[1,2,3,4,1]]
    goalCount = 15;
    Tickers::CuckooTicker.compute_habitat(testMatrix).count.should == goalCount
  end

  it "test flycatchers" do
    testMatrix = NArray[[1,3,3,4,2],[1,3,3,4,2],[1,3,3,4,1],[1,3,3,4,2],[1,3,3,4,2]]
    goalCount = 3;
    Tickers::FlycatcherTicker.compute_habitat(testMatrix).count.should == goalCount
  end

  it "test woodthursh" do
    testMatrix = NArray[[1,3,3,4,2],[1,3,3,4,2],[1,3,3,4,1],[1,3,3,4,2],[1,3,3,4,2]]
    goalCount = 3; # TODO check this and double check with MATLAB
    Tickers::WoodthrushTicker.compute_habitat(testMatrix).count.should == goalCount
  end

  it "test chickadees" do
    testMatrix = NArray[[2,2,2,4,2],[2,2,2,4,2],[2,2,2,4,2],[2,2,2,4,2],[1,2,1,4,1]]
    goalCount = 13;
    Tickers::ChickadeeTicker.compute_habitat(testMatrix).count.should == goalCount
  end

  it "test warbler" do
    testMatrix = NArray[[2,3,2,4,1],[2,3,2,4,1],[2,3,2,4,1],[2,3,2,4,1],[2,2,2,4,1]]
    goalCount = 3; # TODO check this
    Tickers::WarblerTicker.compute_habitat(testMatrix).count.should == goalCount
  end

  it "test timber" do
    testMatrix1 = NArray[[12,13,12,14,11],[8,9,8,9,8],[5,6,7,6,5],[2,3,2,4,1],[2,2,2,4,1]]
    testMatrix2 = NArray[[12,13,12,14,11],[8,9,8,9,8],[5,6,7,6,5],[2,3,2,4,1],[2,2,2,4,1]]
    testMatrix3 = NArray[[12,13,12,14,11],[8,9,8,9,8],[5,6,7,6,5],[2,3,2,4,1],[2,2,2,4,1]]
    goalMatrix1 = NArray[[10140.0007,12462.3002,10140.0007,15110.4524,8123.8982],[4660.1214,6190.3800,4660.1214,6190.3800,4660.1214],[3459.2680,5066.1711,7149.6105,5066.1711,3459.2680],[0,0,0,0,0],[0,0,0,0,0]]
    goalMatrix2 = NArray[[10644.1443,13078.0085,10644.1443,15853.7522,8531.4488],[4324.0072,5736.6677,4324.0072,5736.6676,4324.0072],[2327.8005,3394.4502,4777.1163,3394.4502,2327.8005],[0,0,0,0,0],[0,0,0,0,0]]
    goalMatrix3 = NArray[[8673.7732,10651.5308,8673.7732,12907.1701,6956.9946],[4584.8461,6072.2100,4584.8461,6072.2101,4584.8461],[3611.2440,5239.0527,7347.5178,5239.0527,3611.2440],[0,0,0,0,0],[0,0,0,0,0]]
    result = Tickers::TreeTicker.compute_timber(testMatrix1, testMatrix2, testMatrix3, 1)
    result.bfdt.should approxEqualMatrix(goalMatrix1)
    result.bfmt.should approxEqualMatrix(goalMatrix2)
    result.bfct.should approxEqualMatrix(goalMatrix3)
  end

end
