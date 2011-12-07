require 'spec_helper'

describe Megatile do
  it { should validate_presence_of(:world) }
  it { should belong_to :world }
  it { should belong_to :owner }
  it { should have_many :resource_tiles }
  it { should validate_presence_of :world }

  context "with saved megatiles" do
    let(:new_megatile) { build :megatile, world: saved_tile.world }
    let(:saved_tile) { create :megatile, x:1, y:1 }

    it "will be invalid if duplicate x coordinate for y coordinate" do
      new_megatile.x = 1
      new_megatile.y = 1

      new_megatile.valid?
      new_megatile.errors[:x].should_not be_empty
    end

    it "will be invalid if duplicate y coordinate for x coordinate" do
      new_megatile.x = 1
      new_megatile.y = 1

      new_megatile.valid?
      new_megatile.errors[:y].should_not be_empty
    end

  end

  describe 'factory' do
    it 'should produce multiple valid megatiles' do
      create(:megatile).should be_valid
      build(:megatile).should be_valid
    end
  end

  describe 'geometry' do
    let(:megatile) { build :megatile }
    it "is the worlds megatile width" do
       megatile.width.should == megatile.world.megatile_width
    end
    it "is the worlds megatile height" do
       megatile.height.should == megatile.world.megatile_height
    end
  end

  describe '#spawn_resources' do
    let(:megatile) { create :megatile }
    before { megatile.spawn_resources }
    it "produces the correct number of resource tiles" do
      megatile.reload.resource_tiles.count.should == 9
    end
  end

end
