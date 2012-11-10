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
    let(:player) { create :player }
    let(:tile) { create :deciduous_land_tile }

    let(:template) { build :logging_equipment_template }
    let(:equipment) { LoggingEquipment.generate_from(template) }

    it 'is based on equipment for player' do
      cost = Pricing.clearcut_cost tiles: [tile], player: player
      cost.should == 500
    end
  end
  
end
