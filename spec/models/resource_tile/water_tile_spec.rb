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
    build(:water_tile, zoned_use: "Logging").should_not be_valid
  end

  its(:can_bulldoze?) { should be_false }
  its(:estimated_value) { should be_nil }

  describe 'validation' do
    it 'disallows tree_density' do
      build(:water_tile, tree_density: 1).should_not be_valid
    end
    it 'disallows tree_size' do
      build(:water_tile, tree_size: 1).should_not be_valid
    end
  end

end
