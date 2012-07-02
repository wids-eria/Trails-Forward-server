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

  context "with world" do
    let(:world) { create :world_with_resources }
    let(:player) { create :player, world: world }
    let(:megatile) { world.megatiles.first }
    let(:tile) { create :forest_tile, world: world, megatile: megatile }

    before do
      tile.megatile.owner = player
      tile.tree_density = 1
      tile.tree_size = 1
    end

    it "clear cuts the land" do
      lambda {
        tile.clearcut!
      }.should change(tile, :num_2_inch_diameter_trees).to(0)
      tile.save!
      tile.reload
      tile.land_cover_type.should == :deciduous
    end

  end

  it "can be bulldozed" do
    tile = LandTile.new
    tile.can_bulldoze?.should be_true
  end

  it "bulldozes the land" do
    tile = LandTile.new
    tile.expects(:clear_resources)
    tile.expects(:save!)
    tile.bulldoze!
  end

  it "has estimated value" do
    tile = LandTile.new
    tile.estimated_value.should > 0
  end

  context "#species_group" do
    let(:tile) { LandTile.new }

    it "returns shade tolerant" do
      tile.landcover_class_code = 41
      tile.species_group.should == :shade_tolerant
    end

    it "returns mid tolerant" do
      tile.landcover_class_code = 42
      tile.species_group.should == :mid_tolerant

      tile.landcover_class_code = 90
      tile.species_group.should == :mid_tolerant
    end

    it "returns shade intolerant" do
      tile.landcover_class_code = 43
      tile.species_group.should == :shade_intolerant
    end

    it "raises when unknown class code" do
      tile.landcover_class_code = 95
      lambda {
        tile.species_group
      }.should raise_error('No Trees')

    end
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
    # shade intolerant - softwood - coniferous
    #

    # poletimber - cords
    # sawtimber  - board feet

    it "estimates 2 inch tree value" do
      tile.num_2_inch_diameter_trees = 10
      tile.estimated_2_inch_tree_value.should == 0
    end

    context "shade intolerant" do
      before do
        tile.stubs(species_group: :shade_intolerant)
      end
      it "estimates 6 inch tree value" do
        tile.num_6_inch_diameter_trees = 10
        tile.stubs(calculate_basal_area: 100)
        tile.estimated_6_inch_tree_value.should be_within(0.1).of(2.446338147)
      end

      it "estimates 14 inch tree value" do
        tile.num_14_inch_diameter_trees = 10
        tile.stubs(calculate_basal_area: 100)
        tile.estimated_14_inch_tree_value.should be_within(0.1).of(192.2946)
      end

      # TODO finish test
      # refactor ...
      # yay
      it "estimates 10 inch tree value" do
        tile.num_10_inch_diameter_trees = 10
        tile.stubs(calculate_basal_area: 100)
        tile.estimated_10_inch_tree_value.should be_within(0.1).of(29.0709)
      end
    end

    context "shade tolerant" do
      before do
        tile.stubs(species_group: :shade_tolerant)
      end

      context "when on the tile" do
        it "estimates 6 inch tree value" do
          tile.num_6_inch_diameter_trees = 10
          tile.stubs(calculate_basal_area: 100)
          tile.estimated_6_inch_tree_value.should be_within(0.1).of(3.325163)
        end

        it "estimates 14 inch tree value" do
          tile.num_14_inch_diameter_trees = 10
          tile.stubs(calculate_basal_area: 100)
          tile.estimated_14_inch_tree_value.should be_within(0.1).of(206.1207)
        end

        it "estimates 10 inch tree value" do
          tile.num_10_inch_diameter_trees = 10
          tile.stubs(calculate_basal_area: 100)
          tile.estimated_10_inch_tree_value.should be_within(0.1).of(9.2107)
        end
      end

      context "when passed a tree count" do
        it "estimates 6 inch tree value" do
          tile.stubs(calculate_basal_area: 100)
          tile.estimated_tree_value_for_size(6, 10).should be_within(0.1).of(3.325163)
        end

        it "estimates 6 inch tree value with 0 count" do
          tile.stubs(calculate_basal_area: 100)
          tile.estimated_tree_value_for_size(6, 0).should be_within(0.1).of(0.0)
        end
      end
    end

    context "mid tolerant" do
      before do
        tile.stubs(species_group: :mid_tolerant)
      end
      it "estimates 6 inch tree value" do
        tile.num_6_inch_diameter_trees = 10
        tile.stubs(calculate_basal_area: 100)
        tile.estimated_6_inch_tree_value.should be_within(0.1).of(0.8138)
      end

      it "estimates 14 inch tree value" do
        tile.num_14_inch_diameter_trees = 10
        tile.stubs(calculate_basal_area: 100)
        tile.estimated_14_inch_tree_value.should be_within(0.1).of(125.7250)
      end

      it "estimates 10 inch tree value" do
        tile.num_10_inch_diameter_trees = 10
        tile.stubs(calculate_basal_area: 100)
        tile.estimated_10_inch_tree_value.should be_within(0.1).of(6.6404)
      end
    end

    context "timber value sum" do
      before do
        tile.stubs(species_group: :shade_tolerant)

        tile.stubs(estimated_2_inch_tree_value:   1)
        tile.stubs(estimated_4_inch_tree_value:   2)
        tile.stubs(estimated_6_inch_tree_value:   3)
        tile.stubs(estimated_8_inch_tree_value:   4)
        tile.stubs(estimated_10_inch_tree_value:  5)
        tile.stubs(estimated_12_inch_tree_value:  6)
        tile.stubs(estimated_14_inch_tree_value:  7)
        tile.stubs(estimated_16_inch_tree_value:  8)
        tile.stubs(estimated_18_inch_tree_value:  9)
        tile.stubs(estimated_20_inch_tree_value: 10)
        tile.stubs(estimated_22_inch_tree_value: 11)
        tile.stubs(estimated_24_inch_tree_value: 12)
      end

      it "sums sawtimber value" do
        tile.estimated_sawtimber_value.should == 63
      end

      it "sums poletimber value" do
        tile.estimated_poletimber_value.should == 12
      end
    end

    context "timber volume sum" do
      before do
        tile.stubs(species_group: :shade_tolerant)

        tile.stubs(estimated_2_inch_tree_volume:   1)
        tile.stubs(estimated_4_inch_tree_volume:   2)
        tile.stubs(estimated_6_inch_tree_volume:   3)
        tile.stubs(estimated_8_inch_tree_volume:   4)
        tile.stubs(estimated_10_inch_tree_volume:  5)
        tile.stubs(estimated_12_inch_tree_volume:  6)
        tile.stubs(estimated_14_inch_tree_volume:  7)
        tile.stubs(estimated_16_inch_tree_volume:  8)
        tile.stubs(estimated_18_inch_tree_volume:  9)
        tile.stubs(estimated_20_inch_tree_volume: 10)
        tile.stubs(estimated_22_inch_tree_volume: 11)
        tile.stubs(estimated_24_inch_tree_volume: 12)
      end

      it "sums sawtimber volume" do
        tile.estimated_sawtimber_volume.should == 63
      end

      it "sums poletimber volume" do
        tile.estimated_poletimber_volume.should == 12
      end
    end

    it "converts cubic feet to cords" do
      LandTile.new.cubic_feet_to_cords(26.68).should be_within(0.1).of(0.2084375)
    end
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

    context "tree calculations" do
      before do
        tile.landcover_class_code = 41
        tile.tree_sizes.each{|size| tile.set_trees_in_size(size, 3.0)}
      end

      it "has friggin 36 trees" do
        tile.collect_tree_size_counts.sum.should be_within(0.001).of(36.0)
      end

      it "has a friggin basal area" do
        tile.calculate_basal_area(tile.tree_sizes, tile.collect_tree_size_counts).should be_within(0.0001).of(42.542401)
      end

      it "is mortal" do
        mortality = tile.determine_mortality_rate(2, :shade_tolerant, 80)
        mortality.should be_within(0.001).of(0.0279)
      end

      it "groweth" do
        upgrowth = tile.determine_upgrowth_rate(2, :shade_tolerant, 80, 42.542401)
        upgrowth.should be_within(0.001).of(0.0212)
      end

      it "ingroweth" do
        ingrowth = tile.determine_ingrowth_number(:shade_tolerant, 42.542401)
        ingrowth.should be_within(0.01).of(14.0777)
      end

      context "when it fookin grows" do
        before do
          100.times { tile.grow_trees }
        end

        it "the 2s" do
          tile.trees_in_size(2).should be_within(50).of(250.0)
        end
        it "the 4s" do
          tile.trees_in_size(4).should be_within(10).of(100.0)
        end
        it "the 6s" do
          tile.trees_in_size(6).should be_within(10).of(50.0)
        end
        it "the 8s" do
          tile.trees_in_size(8).should be_within(4).of(28.0)
        end
        it "the 24s" do
          tile.trees_in_size(24).should be_within(0.5).of(1.0)
        end
      end
    end
  end

  context "harvesting trees" do
    let(:tile) { build :deciduous_land_tile }

    before do
      tile.num_2_inch_diameter_trees  = 2
      tile.num_4_inch_diameter_trees  = 4
      tile.num_6_inch_diameter_trees  = 6
      tile.num_8_inch_diameter_trees  = 8
      tile.num_10_inch_diameter_trees = 10
      tile.num_12_inch_diameter_trees = 12
      tile.num_14_inch_diameter_trees = 14
      tile.num_16_inch_diameter_trees = 16
      tile.num_18_inch_diameter_trees = 18
      tile.num_20_inch_diameter_trees = 20
      tile.num_22_inch_diameter_trees = 22
      tile.num_24_inch_diameter_trees = 24
    end

    describe '#excess_tree_counts' do
      it 'returns the number of trees above the requested count' do
        excess = tile.excess_tree_counts [0,0,0,0,10,10,10,10,20,20,20,20]
        excess.should == [2,4,6,8,0,2,4,6,0,0,2,4]
      end
    end

    describe '#position_for_size' do
      it 'returns array index for each size' do
        tile.position_for_size(2).should == 0
        tile.position_for_size(4).should == 1
        tile.position_for_size(6).should == 2
        tile.position_for_size(8).should == 3
        tile.position_for_size(10).should == 4
        tile.position_for_size(12).should == 5
        tile.position_for_size(14).should == 6
        tile.position_for_size(16).should == 7
        tile.position_for_size(18).should == 8
        tile.position_for_size(20).should == 9
        tile.position_for_size(22).should == 10
        tile.position_for_size(24).should == 11
      end
    end

    describe '#sawyer' do
      it "removes trees beyond target diameter distribution" do
        tile.sawyer [14,14,14,14,14,14,14,14,14,14,14,14]

        tile.num_2_inch_diameter_trees.should  == 2
        tile.num_4_inch_diameter_trees.should  == 4
        tile.num_6_inch_diameter_trees.should  == 6
        tile.num_8_inch_diameter_trees.should  == 8
        tile.num_10_inch_diameter_trees.should == 10
        tile.num_12_inch_diameter_trees.should == 12
        tile.num_14_inch_diameter_trees.should == 14
        tile.num_16_inch_diameter_trees.should == 14
        tile.num_18_inch_diameter_trees.should == 14
        tile.num_20_inch_diameter_trees.should == 14
        tile.num_22_inch_diameter_trees.should == 14
        tile.num_24_inch_diameter_trees.should == 14
      end

      # NOTE merchantable height..affected by harvest in weird way.
      #      basal area from old numbers not new?
      context "when returning" do
        let(:values) { tile.sawyer [0,0,0,0,0,0,0,0,0,0,0,0] }

        it "gives poletimber value" do
          values[:poletimber_value].should be_within(0.1).of(16.1415)
        end

        it "gives sawtimber value" do
          values[:sawtimber_value].should be_within(0.1).of(7502.6357)
        end
        

        it "gives poletimber volume" do
          values[:poletimber_volume].should be_within(0.1).of(172.1770)
        end

        it "gives sawtimber volume" do
          values[:sawtimber_volume].should be_within(0.1).of(4526.7747)
        end
      end
    end

    describe "#diameter_limit_cut" do
      it "removes trees above diameter limit" do
        tile.diameter_limit_cut above: 12

        tile.num_2_inch_diameter_trees.should  == 2
        tile.num_4_inch_diameter_trees.should  == 4
        tile.num_6_inch_diameter_trees.should  == 6
        tile.num_8_inch_diameter_trees.should  == 8
        tile.num_10_inch_diameter_trees.should == 10
        tile.num_12_inch_diameter_trees.should == 12
        tile.num_14_inch_diameter_trees.should == 0
        tile.num_16_inch_diameter_trees.should == 0
        tile.num_18_inch_diameter_trees.should == 0
        tile.num_20_inch_diameter_trees.should == 0
        tile.num_22_inch_diameter_trees.should == 0
        tile.num_24_inch_diameter_trees.should == 0
      end

      it "removes trees below diameter limit" do
        tile.diameter_limit_cut below: 12

        tile.num_2_inch_diameter_trees.should  == 0
        tile.num_4_inch_diameter_trees.should  == 0
        tile.num_6_inch_diameter_trees.should  == 0
        tile.num_8_inch_diameter_trees.should  == 0
        tile.num_10_inch_diameter_trees.should == 0
        tile.num_12_inch_diameter_trees.should == 12
        tile.num_14_inch_diameter_trees.should == 14
        tile.num_16_inch_diameter_trees.should == 16
        tile.num_18_inch_diameter_trees.should == 18
        tile.num_20_inch_diameter_trees.should == 20
        tile.num_22_inch_diameter_trees.should == 22
        tile.num_24_inch_diameter_trees.should == 24
      end
    end

    describe "#partial_selection_cut" do
      it "returns a curve" do
        vector = tile.partial_selection_curve target_basal_area: 100.0, qratio: 1.5
        expected_values = [51.82471065214322, 34.54980710142881, 23.033204734285874, 15.35546982285725, 10.236979881904833, 6.824653254603222, 4.549768836402148, 3.033179224268099, 2.022119482845399, 1.348079655230266, 0.8987197701535108, 0.5991465134356738]
        vector.map{|x| x.round(3)}.should == expected_values.map{|x| x.round(3)}
      end

      it "removes trees in excess of target diameter distribution based on basal area and q-ratio" do
        tile.num_2_inch_diameter_trees  = 100
        tile.num_4_inch_diameter_trees  = 1
        tile.num_6_inch_diameter_trees  = 100
        tile.num_8_inch_diameter_trees  = 1
        tile.num_10_inch_diameter_trees = 100
        tile.num_12_inch_diameter_trees = 1
        tile.num_14_inch_diameter_trees = 100
        tile.num_16_inch_diameter_trees = 1
        tile.num_18_inch_diameter_trees = 100
        tile.num_20_inch_diameter_trees = 1
        tile.num_22_inch_diameter_trees = 100
        tile.num_24_inch_diameter_trees = 1

        tile.partial_selection_cut target_basal_area: 100, qratio: 1.5

        tile.num_2_inch_diameter_trees.should  be_within(0.1).of(51.82)
        tile.num_4_inch_diameter_trees.should  be_within(0.1).of(1.000)
        tile.num_6_inch_diameter_trees.should  be_within(0.1).of(23.03)
        tile.num_8_inch_diameter_trees.should  be_within(0.1).of(1.000)
        tile.num_10_inch_diameter_trees.should be_within(0.1).of(10.24)
        tile.num_12_inch_diameter_trees.should be_within(0.1).of(1.000)
        tile.num_14_inch_diameter_trees.should be_within(0.1).of(4.550)
        tile.num_16_inch_diameter_trees.should be_within(0.1).of(1.000)
        tile.num_18_inch_diameter_trees.should be_within(0.1).of(2.022)
        tile.num_20_inch_diameter_trees.should be_within(0.1).of(1.000)
        tile.num_22_inch_diameter_trees.should be_within(0.1).of(0.899)
        tile.num_24_inch_diameter_trees.should be_within(0.1).of(0.599)
      end
    end

    describe '#clearcut' do
      it 'removes all trees' do
        tile.clearcut

        tile.num_2_inch_diameter_trees.should  == 0
        tile.num_4_inch_diameter_trees.should  == 0
        tile.num_6_inch_diameter_trees.should  == 0
        tile.num_8_inch_diameter_trees.should  == 0
        tile.num_10_inch_diameter_trees.should == 0
        tile.num_12_inch_diameter_trees.should == 0
        tile.num_14_inch_diameter_trees.should == 0
        tile.num_16_inch_diameter_trees.should == 0
        tile.num_18_inch_diameter_trees.should == 0
        tile.num_20_inch_diameter_trees.should == 0
        tile.num_22_inch_diameter_trees.should == 0
        tile.num_24_inch_diameter_trees.should == 0
      end
    end
  end

  context "assess marten suitability" do
    let(:tile) { build :deciduous_land_tile }

    before do
      tile.num_2_inch_diameter_trees  = 2
      tile.num_4_inch_diameter_trees  = 4
      tile.num_6_inch_diameter_trees  = 6
      tile.num_8_inch_diameter_trees  = 8
      tile.num_10_inch_diameter_trees = 10
      tile.num_12_inch_diameter_trees = 12
      tile.num_14_inch_diameter_trees = 14
      tile.num_16_inch_diameter_trees = 16
      tile.num_18_inch_diameter_trees = 18
      tile.num_20_inch_diameter_trees = 20
      tile.num_22_inch_diameter_trees = 22
      tile.num_24_inch_diameter_trees = 24
    end


    describe '#assess suitability' do
      it 'checks the suitability of a tile for marten' do
        #tile.memoize_basal_area true #force
        tile.calculate_marten_suitability.should == 1
      end
    end
  end

  context "#basal_area_for_size" do
    let(:tile) { LandTile.new }
    it "fookin works" do
      tile.basal_area_for_size(2).should be_within(0.0001).of(0.0218166)
    end
  end
end
