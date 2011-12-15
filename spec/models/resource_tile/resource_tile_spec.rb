require 'spec_helper'

describe ResourceTile do
  it { should have_many :agents }
  let(:resource_tile) { build :resource_tile }

  describe 'scope' do
    describe '.within_rectangle' do
      let(:world) { create :world_with_tiles }
      before do
        ResourceTile.delete_all
        world
      end
      it 'returns resource tiles within the passed in rectangle coordinates' do
        tiles = ResourceTile.within_rectangle x: 2, y: 1, width: 2, height: 3
        tiles.count.should == 6
        tiles.map(&:location).should == [[2,1], [2,2], [2,3], [3,1], [3,2], [3,3]]
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
