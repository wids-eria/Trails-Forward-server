require 'spec_helper'

describe Megatile do
  it { should validate_presence_of(:world) }
  it { should belong_to :world }
  it { should belong_to :owner }
  it { should have_many :resource_tiles }
  it { should validate_presence_of :world }

  context "with saved megatiles" do
    let(:saved_tile) { create(:world_with_tiles).megatiles.first }
    let(:new_megatile) { build :megatile, world: saved_tile.world, x: saved_tile.x, y: saved_tile.y }
    before { new_megatile.valid? }

    it "will be invalid if duplicate x coordinate for y coordinate" do
      new_megatile.errors[:x].should_not be_empty
    end

    it "will be invalid if duplicate y coordinate for x coordinate" do
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

  context 'Listings' do
    let!(:listing) { create :listing }
    let!(:listing2) { create :listing, megatile_grouping: listing.megatile_grouping, owner: listing.owner}
    let!(:dead_listing) { create :listing, megatile_grouping: listing.megatile_grouping, owner: listing.owner, status: 'Dead'}
    let(:megatile) { listing.megatile_grouping.megatiles.first }
    describe '#listings' do
      it "returns listings" do
        megatile.listings.to_set.should == [listing, listing2, dead_listing].to_set
      end
    end

    describe '#active_listings' do
      it "returns listings" do
        megatile.active_listings.to_set.should == [listing, listing2].to_set
      end
    end
  end

  context "Bids" do
    let!(:bid) { create :bid }
    let!(:bid_without_offer) { create :bid, requested_land: bid.requested_land, status: 'Rejected' }
    let(:megatile) { bid.requested_land.megatiles.first}

    describe "#bids_on" do
      it "returns bids" do
        megatile.bids_on.to_set.should == [bid, bid_without_offer].to_set
      end
    end

    describe "#active_bids_on" do
      it "returns bids on with offers" do
        megatile.active_bids_on.to_set.should == [bid].to_set
      end
    end
  end
end
