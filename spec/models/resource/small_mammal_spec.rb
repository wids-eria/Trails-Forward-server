require 'spec_helper'
#require 'app/models/resource/small_mammals'

describe SmallMammal do
  it 'should grow' do
    mammal = SmallMammal.new
    mammal.value = 1
    mammal.grow
    mammal.value.should > 1
  end

  it 'grow at zero' do
    mammal = SmallMammal.new
    mammal.value = 0
    mammal.grow
    mammal.value.should == 0
  end

  it 'should not grow' do
    mammal = SmallMammal.new
    mammal.value = 55
    mammal.grow
    mammal.value.should < 55
  end
end
