require 'spec_helper'

describe World do
  let(:world) { build :world }
  let(:pricing) { Pricing.new world}
  
  describe "Wood Pricing" do
    it "values pine sawtimber at the base price if no chopping or buying has happened" do
      pricing.pine_sawtimber_price.should == world.pine_sawtimber_base_price
    end
    
    it "values pine sawtimber less if there is a lot made but none used" do
      puts world.inspect
      world.pine_sawtimber_cut_this_turn = 1000
      pricing.pine_sawtimber_price.should < world.pine_sawtimber_base_price
    end
    
    it "values pine sawtimber more if there is a lot used but none made" do
      puts world.inspect
      world.pine_sawtimber_used_this_turn = 1000
      pricing.pine_sawtimber_price.should > world.pine_sawtimber_base_price
    end
    
    it "values pine sawtimber at the base price if supply equals demand" do
      puts world.inspect
      world.pine_sawtimber_used_this_turn = 1000
      world.pine_sawtimber_cut_this_turn = 1000
      pricing.pine_sawtimber_price.should be_within(0.0001).of(world.pine_sawtimber_base_price)
    end
    
  end
  
end