require 'spec_helper'

describe Broker do
  let(:seller) { create :player }
  let(:world) { seller.world }
  let(:bidder) { create :player, world: world }
  let(:sellers_tile) { world.megatiles.first }
  let(:requested_land) { create :megatile_grouping, megatiles: [sellers_tile] }
  let(:offered_land) { create :megatile_grouping, megatiles: [sellers_tile] }

  before do
    sellers_tile.update_attributes(owner: seller)
  end

  context "unsolicited bid" do
    let!(:bid) { Bid.create! bidder: bidder, current_owner: seller, money: 1000, requested_land: requested_land }
    before do
      bid.accept!
    end

    describe "#process_sale" do
      before do
        world.manager.broker.process_sale(bid)
      end

      it "changes owner to bidder" do
        sellers_tile.reload
        sellers_tile.owner.should == bidder
      end

      it "gives seller balance" do
        seller.reload
        seller.balance.should == 1100
      end
    end

    it "processes bid on a tile with listings" do
      listing = Factory.create :listing, megatile_grouping: offered_land, owner: seller

      world.manager.broker.process_sale(bid)
    end
  end

  it "accepts a bid for a listing on a tile with one listing"

  it "accepts a bid for a listing on a tile with multiple listings"
end
