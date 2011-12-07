require 'spec_helper'

describe World do
  describe 'factory' do
    it 'should produce multiple valid worlds' do
      create(:world).should be_valid
      build(:world).should be_valid
    end
  end

  context "when first created" do
    let(:world) { create :world }
    subject { world }
    its(:resource_tiles) { should be_empty }
    its(:megatiles) { should be_empty }
    its(:players) { should be_empty }
  end

  context "when initialized with dummy data" do
    let(:world) { create :world_with_properties }
    subject { world }
    its(:resource_tiles) { should_not be_empty }
    its(:megatiles) { should_not be_empty }
    its(:players) { should_not be_empty }
  end

  describe "#coords" do
    let(:world) { build :world, height: 2, width: 2 }
    it "returns array of coordinate pair arrays" do
      world.coords.should == [[0,0],[0,1],[1,0],[1,1]]
    end
  end

  describe "#megatile_coords" do
    let(:world) { build :world, height: 6, width: 6, megatile_height: 3, megatile_width: 3 }
    it "returns each megatile's first tile's coordinate pair in an array" do
      world.megatile_coords.should == [[0,0],[0,3],[3,0],[3,3]]
    end
  end

end
