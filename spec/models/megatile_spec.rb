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

  end

  describe 'factory' do
    it 'should produce multiple valid megatiles' do
      create(:megatile).should be_valid
      build(:megatile).should be_valid
    end
  end

end
