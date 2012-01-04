require 'spec_helper'

describe WaterTile do
  subject { WaterTile.new }

  describe 'factory' do
    it 'should produce multiple valid water tiles' do
      create(:water_tile).should be_valid
      build(:water_tile).should be_valid
    end
  end

  it "cannot be zoned for logging" do
    build(:water_tile, zoning_code: 6).should_not be_valid
  end

  its(:can_bulldoze?) { should be_false }
  its(:estimated_value) { should be_nil }

  describe '#permitted_actions' do
    let(:water_tile) { create :water_tile }
    let(:owner) { create :player, world_id: water_tile.world_id }
    let(:other_player) { create :player, world_id: water_tile.world_id }
    before { water_tile.megatile.update_attributes owner: owner }

    subject { water_tile.permitted_actions(target_player) }
    context 'on an owned tile' do
      let(:target_player) { owner }
      it { should == [] }
    end

    context 'on an unowned tile' do
      let(:target_player) { other_player }
      it { should == [] }
    end
  end

  describe 'validation' do
    it 'disallows tree_density' do
      build(:water_tile, tree_density: 1).should_not be_valid
    end
    it 'disallows tree_size' do
      build(:water_tile, tree_size: 1).should_not be_valid
    end
  end

end
