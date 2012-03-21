require 'spec_helper'

describe Bid do
  it { should belong_to :bidder }
  it { should belong_to :current_owner }
  it { should belong_to :listing }

  it { should belong_to :counter_to }
  it { should have_many :counter_bids }

  it { should belong_to :offered_land }
  it { should belong_to :requested_land } 

  it { should validate_presence_of :money }
  it { should validate_presence_of :requested_land }
  it { should validate_numericality_of :money }

  describe 'factory' do
    it 'should produce multiple valid bids' do
      create(:bid).should be_valid
      build(:bid).should be_valid
    end
  end

  describe 'validation' do
    describe 'money' do
      it 'disallows negative amounts' do
        build(:bid, money: -1.50).should_not be_valid
      end
    end
    describe 'requested_land' do
      context 'with multiple owners' do
        before :all do
          Player.count.should == 0
        end

        let(:ben) { create :player }
        let(:world) { ben.world }
        let(:kevin) { create :player, world: world }
        let(:bens_tile) { world.megatiles.first }
        let(:kevins_tile) { world.megatiles.last }
        let(:requested_land) { create :megatile_grouping, megatiles: [kevins_tile, bens_tile] }

        before do
          bens_tile.update_attributes(owner: ben)
          kevins_tile.update_attributes(owner: kevin)
        end

        it 'is not valid' do
          build(:bid, requested_land: requested_land).should_not be_valid
        end
      end
    end
  end

  context "Scopes" do
    describe ".active" do
      let!(:bid1) { create :bid, status: Bid.verbiage[:active] }
      let!(:bid2) { create :bid, status: Bid.verbiage[:cancelled] }
      it "returns active bids" do
        Bid.active.should == [bid1]
      end
    end
  end

  context "States" do
    let(:bid) { build :bid, status: Bid.verbiage[:active] }

    describe "#accept" do
      it "should change status to accepted" do
        bid.accept
        bid.status.should == Bid.verbiage[:accepted]
      end
    end

    describe "#accepted?" do
      it "returns true or false based on status" do
        bid.accepted?.should == false
        bid.accept
        bid.accepted?.should == true
      end
    end
  end

  context "Listings" do
    describe "requested_land" do
      let(:listing) { create :listing }
      let(:bid) { create :bid, requested_land: nil, listing: listing }
      it "is the same as the listing when present" do
        bid.requested_land.megatiles.should == listing.megatile_grouping.megatiles
        bid.requested_land.should == listing.megatile_grouping
      end
    end
  end
end
