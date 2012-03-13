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
        land_tile.stubs(can_bulldoze?: true)
        land_tile.stubs(can_clearcut?: true)
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
        land_tile.stubs(can_bulldoze?: true)
        land_tile.stubs(can_clearcut?: false)
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
        land_tile.stubs(can_bulldoze?: false)
        land_tile.stubs(can_clearcut?: false)
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
      tile.save!
      tile.reload
      tile.land_cover_type.should == :barren
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
    tile.expects(:clear_resources)
    tile.bulldoze!
  end

  it "has estimated value" do
    tile = LandTile.new
    tile.estimated_value.should > 0
  end

  context "timber value" do
    let(:tile) { LandTile.new }

    # size class hardwood
    # 0 - 4 worthless
    # 6 - 10 poletimber
    # 12+ sawtimber
    #
    # softwood
    # 0 - 4 worthless
    # 6 - 8 poletimber
    # 10+ sawtimber
    #

    # wood mapping
    # shade tolerant   - hardwood - deciduous
    # mid tolerant     - mixed    - mixed
    # shade intolerant - softwood - coniforous
    #

    # poletimber - cords
    # sawtimber  - board feet

    it "estimates 2 inch tree value" do
      tile.num_2_inch_diameter_trees = 10
      tile.estimated_2_inch_tree_value.should == 0
    end

    it "estimates 6 inch coniforous tree value" do
      tile.num_6_inch_diameter_trees = 10
      tile.stubs(calculate_basal_area: 100)
      tile.estimated_6_inch_tree_value.should be_within(0.1).of(2.084375)
    end

    it "estimates 14 inch coniforous tree value" do
      tile.num_14_inch_diameter_trees = 10
      tile.stubs(calculate_basal_area: 100)
      tile.estimated_14_inch_tree_value.should be_within(0.1).of(310.392508)
    end

    # TODO
    # refactor 6 and 14
    #

    it "estimates 6 inch deciduous tree value"
    it "estimates 14 inch deciduous tree value"

    # test switching
    it "estimates 10 inch coniforous tree value"
    it "estimates 10 inch deciduous tree value"


    it "sums by product type"

    it "converts cubic feet to cords" do
      LandTile.new.cubic_feet_to_cords(26.68).should be_within(0.1).of(0.2084375)
    end


    it "converts all the hethens"
    
  end

  describe '#grow_trees' do
    let(:megatile) { Factory :megatile }
    let(:tile) { World.new.deciduous_land_tile [1,1], megatile.id }
    let(:tile_variant) { World.new.deciduous_land_tile_variant [1,1], megatile.id }

    # example "applies tree mortality rate" do
      # old_num_trees = (2..24).step(2).map{|n| tile.send("num_#{n}_inch_diameter_trees".to_sym)}.sum
      # old_num_trees.should == 72
      # tile.grow_trees
      # new_num_trees = (2..24).step(2).map{|n| tile.send("num_#{n}_inch_diameter_trees".to_sym)}.sum
      # new_num_trees.should < old_num_trees
    # end

    example 'applies the upgrowth rate' do
      old_num_trees = (2..24).step(2).map{|n| tile.send("num_#{n}_inch_diameter_trees".to_sym)}.sum
      old_num_trees.should == 72
      tile.grow_trees
      new_num_trees = (2..24).step(2).map{|n| tile.send("num_#{n}_inch_diameter_trees".to_sym)}.sum

      new_num_trees.should > old_num_trees
    end

    example 'applies the upgrowth rate to the variant' do
      old_num_trees = (2..24).step(2).map{|n| tile_variant.send("num_#{n}_inch_diameter_trees".to_sym)}.sum
      tile_variant.grow_trees
      new_num_trees = (2..24).step(2).map{|n| tile_variant.send("num_#{n}_inch_diameter_trees".to_sym)}.sum

      new_num_trees.should < old_num_trees
    end
  end

end
