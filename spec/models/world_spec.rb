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

end
