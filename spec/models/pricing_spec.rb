require 'spec_helper'

describe Pricing do
  let(:world) { build :world }
  let(:pricing) { Pricing.new world}
  
  describe "Wood Pricing" do
    it "values pine sawtimber at the base price if no chopping or buying has happened" do
      pricing.pine_sawtimber_price.should == world.pine_sawtimber_base_price
    end
    
    it "values pine sawtimber less if there is a lot made but none used" do
      world.pine_sawtimber_cut_this_turn = 1000
      pricing.pine_sawtimber_price.should < world.pine_sawtimber_base_price
    end
    
    it "values pine sawtimber more if there is a lot used but none made" do
      world.pine_sawtimber_used_this_turn = 1000
      pricing.pine_sawtimber_price.should > world.pine_sawtimber_base_price
    end
    
    it "values pine sawtimber at the base price if supply equals demand" do
      world.pine_sawtimber_used_this_turn = 1000
      world.pine_sawtimber_cut_this_turn = 1000
      pricing.pine_sawtimber_price.should be_within(0.0001).of(world.pine_sawtimber_base_price)
    end
    
  end

  describe '#clearcut_cost' do
    let(:player) { build :player, logging_equipment: [equipment, equipment2] }
    let(:tile)  { build :deciduous_land_tile }
    let(:tile2) { build :deciduous_land_tile }

    let(:template) { build :logging_equipment_template }
    let(:equipment)  { LoggingEquipment.generate_from(template) }
    let(:equipment2) { LoggingEquipment.generate_from(template) }

    context "with stubbed data" do
      describe "#clearcut_cost" do
        before do
          tile.stubs(estimated_2_inch_tree_volume:  0.0)
          tile.stubs(estimated_4_inch_tree_volume:  0.0)
          tile.stubs(estimated_6_inch_tree_volume:  0.0)
          tile.stubs(estimated_8_inch_tree_volume:  0.0)
          tile.stubs(estimated_10_inch_tree_volume: 0.0)
          tile.stubs(estimated_12_inch_tree_volume: 0.0)
          tile.stubs(estimated_14_inch_tree_volume: 0.0)
          tile.stubs(estimated_16_inch_tree_volume: 0.0)
          tile.stubs(estimated_18_inch_tree_volume: 0.0)
          tile.stubs(estimated_20_inch_tree_volume: 0.0)
          tile.stubs(estimated_22_inch_tree_volume: 0.0)
          tile.stubs(estimated_24_inch_tree_volume: 300.0)

          tile2.stubs(estimated_2_inch_tree_volume:  100.0) # should not affect
          tile2.stubs(estimated_4_inch_tree_volume:  200.0) # half as fast
          tile2.stubs(estimated_6_inch_tree_volume:  0.0)
          tile2.stubs(estimated_8_inch_tree_volume:  0.0)
          tile2.stubs(estimated_10_inch_tree_volume: 0.0)
          tile2.stubs(estimated_12_inch_tree_volume: 0.0)
          tile2.stubs(estimated_14_inch_tree_volume: 0.0)
          tile2.stubs(estimated_16_inch_tree_volume: 0.0)
          tile2.stubs(estimated_18_inch_tree_volume: 0.0)
          tile2.stubs(estimated_20_inch_tree_volume: 0.0)
          tile2.stubs(estimated_22_inch_tree_volume: 0.0)
          tile2.stubs(estimated_24_inch_tree_volume: 600.0)

          equipment.operating_cost = 1500
          equipment.diameter_range_min = 2
          equipment.diameter_range_max = 24

          equipment2.operating_cost = 2100
          equipment2.diameter_range_min = 14
          equipment2.diameter_range_max = 24
        end

        it 'is based on cost from all tiles' do
          cost = Pricing.clearcut_cost tiles: [tile, tile], player: player
          cost.should == 500
        end

        it 'is based on time and rate for tile' do
          cost = Pricing.clearcut_cost_for_tile tile: tile, player: player
          cost.should == 500
        end

        context 'for diameter'  do
          before do
            TimeManager.stubs(clearcut_cost_for_diameter: 0.5)
          end

          it 'is based on time and rate for diameter' do
            cost = Pricing.clearcut_cost_for_diameter tile: tile, diameter: 12, player: player
            cost.should == 750.0
          end
        end
      end
    end

    context "with real data" do
      it 'actually works'
    end
  end
  
end
