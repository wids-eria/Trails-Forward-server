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

  describe "#migrate_population_to_most_desirable_tiles!" do
    let(:world) { create :world_with_resources, :width => 42, :height => 42 }
    it "migrates people to the best spots" do
      rt = world.resource_tile_at 2, 2
      rt.total_desirability_score = 10
      rt.housing_capacity = 42
      rt.housing_occupants = 0
      rt.save!
      world.migrate_population_to_most_desirable_tiles! 1
      rt.reload
      rt.housing_occupants.should == 1
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

  context "when there are houses and people" do
    let!(:world) { create :world  }
    let!(:tile1) { create :resource_tile, world: world, housing_capacity: 5, housing_occupants: 0 }
    let!(:tile2) { create :resource_tile, world: world, housing_capacity: 5, housing_occupants: 5 }
    let!(:tile3) { create :resource_tile, world: world, housing_capacity: 5, housing_occupants: 5 }
    let!(:tile4) { create :resource_tile, world: world, housing_capacity: 0 }
    describe "#human_population" do
      it "returns sum of people on all tiles" do
        world.human_population.should == 10
      end
    end

    describe "#livable_tiles_count" do
      it "returns count of tiles that have housing capacity" do
        world.livable_tiles_count.should == 3
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
