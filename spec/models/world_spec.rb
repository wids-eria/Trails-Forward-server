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

  context "world api" do
    let(:world) { build :world, start_date: Date.today - 10.days, current_date: Date.today }

    # NOTE just to get the api working like it used to
    describe "#year_current" do
      it "returns the year from the current date" do
        world.year_current.should == Date.today.year
      end
    end

    describe "#year_start" do
      it "returns the year from the start date" do
        world.year_start.should == (Date.today-10.days).year
      end
    end
  end

  describe "#marten_population" do
    let!(:world) {create :world}
    let!(:tile_1) {create :deciduous_land_tile, :num_24_inch_diameter_trees => 12, :num_20_inch_diameter_trees => 10, :world => world}
    let!(:tile_2) {create :deciduous_land_tile, :num_24_inch_diameter_trees => 12, :num_20_inch_diameter_trees => 10, :world => world}
    let!(:tile_3) {create :deciduous_land_tile, :num_24_inch_diameter_trees => 12, :num_20_inch_diameter_trees => 10, :world => world}
    let!(:tile_4) {create :deciduous_land_tile, :world => world}
    let!(:tile_5) {create :deciduous_land_tile_variant, :world => world}
    let!(:tile_6) {create :deciduous_land_tile_variant, :num_18_inch_diameter_trees => 0, :num_20_inch_diameter_trees => 0, :num_22_inch_diameter_trees => 0, :num_24_inch_diameter_trees => 0, :world => world}
  
    it "returns count of martens in the world" do
      #debugger
      world.update_marten_suitability
      world.marten_suitable_tile_count.should == 6
    end
  end

  describe '#year_current' do
    let(:world) { create :world, start_date: Date.today }
    it 'doesnt overflow from database' do
      world.current_date = world.start_date + 99999.years
      world.save!

      world.reload
      world.year_current.should == world.start_date.year + 99999

      world.current_date.should == world.start_date + 99999.years
    end
  end

end
