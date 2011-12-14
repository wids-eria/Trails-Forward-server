require 'spec_helper'

describe ResourceTile do
  it { should have_many :agents }
  let(:resource_tile) { build :resource_tile }

  describe 'scope' do
    describe '.within_rectangle' do
      it 'returns resource tiles withing the passed in rectangle coordinates' do
        tiles = ResourceTile.within_rectangle x: 2, y: 10, width: 2, height: 3
        tiles.count = 6
        tiles.first.x.should == 2
        tiles.first.y.should == 10
        tiles.first.x.should == 3
        tiles.first.x.should == 12
      end
    end
  end

  describe '#location=' do
    it 'assigns coords to x and y' do
      resource_tile.location = [4, 5]
      resource_tile.x.should == 4
      resource_tile.y.should == 5
    end
  end

  describe '#location' do
    it 'returns array of [x,y] values' do
      resource_tile = build(:resource_tile, x: 1, y:3)
      resource_tile.location.should == [1, 3]
    end
  end
end
