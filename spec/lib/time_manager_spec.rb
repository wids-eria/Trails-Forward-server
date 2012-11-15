require 'spec_helper'

describe TimeManager do
  let(:template) { build :logging_equipment_template }
  let(:equipment1) { LoggingEquipment.generate_from(template) }
  let(:equipment2) { LoggingEquipment.generate_from(template) }
  let(:player) { build :player, logging_equipment: [equipment1, equipment2] }

  let(:deciduous_tile1) { build :deciduous_land_tile }
  let(:deciduous_tile2) { build :deciduous_land_tile }

  let(:tiles) { [deciduous_tile1, deciduous_tile2] }

  before do
    equipment1.harvest_volume = 1000
    equipment1.diameter_range_min = 6
    equipment1.diameter_range_max = 24

    equipment2.harvest_volume = 500
    equipment2.diameter_range_min = 4
    equipment2.diameter_range_max = 24
  end

  context "with stubbed volumes" do
    before do
      deciduous_tile1.stubs(estimated_2_inch_tree_volume:  0.0)
      deciduous_tile1.stubs(estimated_4_inch_tree_volume:  0.0)
      deciduous_tile1.stubs(estimated_6_inch_tree_volume:  0.0)
      deciduous_tile1.stubs(estimated_8_inch_tree_volume:  0.0)
      deciduous_tile1.stubs(estimated_10_inch_tree_volume: 0.0)
      deciduous_tile1.stubs(estimated_12_inch_tree_volume: 0.0)
      deciduous_tile1.stubs(estimated_14_inch_tree_volume: 0.0)
      deciduous_tile1.stubs(estimated_16_inch_tree_volume: 0.0)
      deciduous_tile1.stubs(estimated_18_inch_tree_volume: 0.0)
      deciduous_tile1.stubs(estimated_20_inch_tree_volume: 0.0)
      deciduous_tile1.stubs(estimated_22_inch_tree_volume: 0.0)
      deciduous_tile1.stubs(estimated_24_inch_tree_volume: 300.0)

      deciduous_tile2.stubs(estimated_2_inch_tree_volume:  100.0) # should not affect
      deciduous_tile2.stubs(estimated_4_inch_tree_volume:  200.0) # half as fast
      deciduous_tile2.stubs(estimated_6_inch_tree_volume:  0.0)
      deciduous_tile2.stubs(estimated_8_inch_tree_volume:  0.0)
      deciduous_tile2.stubs(estimated_10_inch_tree_volume: 0.0)
      deciduous_tile2.stubs(estimated_12_inch_tree_volume: 0.0)
      deciduous_tile2.stubs(estimated_14_inch_tree_volume: 0.0)
      deciduous_tile2.stubs(estimated_16_inch_tree_volume: 0.0)
      deciduous_tile2.stubs(estimated_18_inch_tree_volume: 0.0)
      deciduous_tile2.stubs(estimated_20_inch_tree_volume: 0.0)
      deciduous_tile2.stubs(estimated_22_inch_tree_volume: 0.0)
      deciduous_tile2.stubs(estimated_24_inch_tree_volume: 600.0)
    end

    describe '#clearcut_cost' do
      it 'is based on total costs of all diameters on all tiles' do
        TimeManager.clearcut_cost(tiles: tiles, player: player).should == 1.0
      end
    end

    describe '#clearcut_cost_per_tile' do
      it 'is based on total cost on a tile' do
        TimeManager.clearcut_cost_for_tile(tile: deciduous_tile2, player: player).should == 0.8
      end
    end

    describe '#clearcut_cost_per_diameter' do
      it 'is based on equipment for player and volume' do
        TimeManager.clearcut_cost_for_diameter(tile: deciduous_tile1, diameter: 24, player: player).should == 0.2
      end
    end
  end

  context "with a real tile information" do
    describe "#clearcut_cost" do
      it 'is based on total cost of all diameters on all tiles' do
        TimeManager.clearcut_cost(tiles: tiles, player: player).should == 1.0 # not gonna be 1
      end
    end
  end
end
