require 'spec_helper'

describe LandTile do
  describe 'factory' do
    it 'should produce multiple valid land tiles' do
      create(:land_tile).should be_valid
      build(:land_tile).should be_valid
    end
  end

  describe '#permitted_actions' do
    let(:land_tile) { create :land_tile }
    let(:owner) { create :player, world_id: land_tile.world_id }
    let(:other_player) { create :player, world_id: land_tile.world_id }
    before { land_tile.megatile.update_attributes owner: owner }

    subject { land_tile.permitted_actions target_player }

    context 'when all actions are permitted' do
      before do
        land_tile.stub(can_bulldoze?: true)
        land_tile.stub(can_clearcut?: true)
      end

      context 'on an owned tile' do
        let(:target_player) { owner }
        it { should == ['bulldoze', 'clearcut'] }
      end

      context 'on an unowned tile' do
        let(:target_player) { other_player }
        it { should == [] }
      end
    end

    context 'some actions are permitted' do
      before do
        land_tile.stub(can_bulldoze?: true)
        land_tile.stub(can_clearcut?: false)
      end

      context 'on an owned tile' do
        let(:target_player) { owner }
        it { should == ['bulldoze'] }
      end

      context 'on an unowned tile' do
        let(:target_player) { other_player }
        it { should == [] }
      end
    end

    context 'when no actions are permitted' do
      before do
        land_tile.stub(can_bulldoze?: false)
        land_tile.stub(can_clearcut?: false)
      end

      context 'on an owned tile' do
        let(:target_player) { owner }
        it { should == [] }
      end

      context 'on an unowned tile' do
        let(:target_player) { other_player }
        it { should == [] }
      end
    end
  end

  [1..17].each do |zoning_code|
    example "zoning_code #{zoning_code} can be clear cut" do
      tile = LandTile.new zoning_code: zoning_code
      tile.can_clearcut?.should be_true
    end
  end
  example "zoning_code 255 cannot be clear cut" do
    tile = LandTile.new zoning_code: 255
    tile.can_clearcut?.should be_false
  end

  context "with world" do
    let(:world) { create :world_with_resources }
    let(:player) { create :player, world: world }
    let(:megatile) { world.megatiles.first }
    let(:tile) { megatile.world.resource_tiles.select{|tile| tile.kind_of?(LandTile)}.first }
    before do
      tile.megatile.owner = player
      tile.tree_density = 1
      tile.tree_size = 1
    end

    it "clear cuts the land" do
      lambda {
        tile.clearcut!
      }.should change(tile, :tree_density).to(0.0)
    end

    it "awards tile owner the lumber value when clearcut" do
      lambda {
        tile.clearcut!
      }.should change { tile.megatile.owner.balance }
    end
  end

  it "can be bulldozed" do
    tile = LandTile.new
    tile.can_bulldoze?.should be_true
  end

  it "bulldozes the land" do
    tile = LandTile.new
    tile.should_receive(:clear_resources)
    tile.bulldoze!
  end

  it "has estimated value" do
    tile = LandTile.new
    tile.estimated_value.should > 0
  end

  context "trees" do
    let(:tile) { LandTile.new tree_density: 1, tree_size: 0.5 }

    it "should have estimated lumber value" do
      tile.estimated_lumber_value.should == 21
    end
  end

  describe '.grow_trees!' do
    let(:world) { create :world_with_resources }
    let(:tile) { world.resource_tiles.where('type = ? AND tree_density > 0', 'LandTile').first }

    example 'increases the tree_density' do
      original_density = tile.tree_density
      world.grow_trees!
      tile.reload.tree_density.should > original_density
    end
  end

end
