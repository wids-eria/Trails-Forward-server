require 'spec_helper'

describe ResourceTile do
  it { should have_many :agents }
  it { should validate_presence_of :zone_type }
  it { should validate_presence_of :landcover_class_code }
  let(:resource_tile) { build :resource_tile }

  describe 'scope' do
    describe '.with_trees' do
      it 'returns only land tiles with trees' do
        forest = create :forest_tile
        create :grass_tile
        create :water_tile
        ResourceTile.with_trees.should == [forest]
      end
    end

    describe '.in_square_range' do
      let(:world) { create :world_with_tiles }
      let(:corner_agent) { create :generic_agent, world: world, location: [3, 3] }
      let(:center_agent) { create :generic_agent, world: world, location: [2.5, 2.5] }

      subject { ResourceTile.in_square_range(radius, *location).map(&:location).sort }

      context 'corner agent' do
        let(:location) { corner_agent.location }

        context 'in radius 0' do
          let(:radius) { 0 }
          it { should == [[3,3]].sort }
        end

        context 'in radius 1' do
          let(:radius) { 1 }
          it { should == [[2,2],[3,2],
                          [2,3],[3,3]].sort }
        end

        context 'in radius 2.5' do
          let(:radius) { 2.5 }
          it { should == [[0,0],[1,0],[2,0],[3,0],[4,0],[5,0],
                          [0,1],[1,1],[2,1],[3,1],[4,1],[5,1],
                          [0,2],[1,2],[2,2],[3,2],[4,2],[5,2],
                          [0,3],[1,3],[2,3],[3,3],[4,3],[5,3],
                          [0,4],[1,4],[2,4],[3,4],[4,4],[5,4],
                          [0,5],[1,5],[2,5],[3,5],[4,5],[5,5]].sort }
        end
      end

      context 'centered agent' do
        let(:location) { center_agent.location }

        context 'in radius 0' do
          let(:radius) { 0 }
          it { should == [[2,2]].sort }
        end

        context 'in radius 1' do
          let(:radius) { 1 }
          it { should == [[1,1],[2,1],[3,1],
                          [1,2],[2,2],[3,2],
                          [1,3],[2,3],[3,3]].sort }
        end

        context 'in radius 2' do
          let(:radius) { 2 }
          it { should == [[0,0],[1,0],[2,0],[3,0],[4,0],
                          [0,1],[1,1],[2,1],[3,1],[4,1],
                          [0,2],[1,2],[2,2],[3,2],[4,2],
                          [0,3],[1,3],[2,3],[3,3],[4,3],
                          [0,4],[1,4],[2,4],[3,4],[4,4]].sort }
        end
      end
    end

    describe '.within_rectangle' do
      let(:world) { create :world_with_tiles }
      before do
        ResourceTile.delete_all
        world
      end
      it 'returns resource tiles within the passed in rectangle coordinates' do
        tiles = ResourceTile.within_rectangle x_min: 2, y_min: 1, x_max: 3, y_max: 3
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

  describe '#residue' do
    let(:tile) { build :resource_tile }
    it 'serializes a hash' do
      tile.residue[:marten_id] = 123
      tile.save!
      tile.reload
      tile.residue.should == {marten_id: 123}
    end
  end

  describe '#population' do
    let(:tile) { build :resource_tile }
    it 'serializes a hash' do
      tile.population[:voles] = 123
      tile.save!
      tile.reload
      tile.population.should == {voles: 123}
    end
  end
  
end
