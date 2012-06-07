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

  describe "#tick" do
    let(:world) { create :world }
    let(:start_date) { world.start_date }

    subject{ world }

    before do
      world.stubs(tick_agents: true,
                 tick_tiles: true,
                 tick_length: 1.day)
      world.tick
    end

    its(:current_date) { should == world.start_date + 1.day }
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
    describe "#human_population" do
      it "returns sum of people on all tiles"
    end

    describe "#livable_tiles_count" do
      it "returns count of tiles that have housing capacity"
    end
  end

  describe "#marten_population" do
    let(:world) { create :world_with_resources, :width => 9, :height => 9 }
    it "returns count of martens in the world" do
      world.update_marten_suitable_tile_count
      world.marten_suitable_tile_count.should == world.resource_tiles.marten_suitable.count
    end
  end

end
