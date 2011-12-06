require 'spec_helper'

describe ResourceTile do
  it { should have_many :agents }
  let(:resource_tile) { build :resource_tile }

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
