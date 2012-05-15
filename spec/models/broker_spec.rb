require 'spec_helper'

describe Broker do
  let!(:seller) { create :player }
  let!(:world) { seller.world }
  let!(:bidder) { create :player, world: world }
  let!(:sellers_tile) { world.megatiles.first }
  let!(:requested_land) { create :megatile_grouping, megatiles: [sellers_tile] }
  let!(:offered_land) { create :megatile_grouping, megatiles: [sellers_tile] }

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
        seller.balance.should == 2000
      end
    end

    it "processes bid on a tile with listings" do
      listing = Factory.create :listing, megatile_grouping: offered_land, owner: seller

      world.manager.broker.process_sale(bid)
    end
    it "processes a bid on a tile with multiple bids" do
      bid2 = Bid.create! bidder: bidder, current_owner: seller, money: 1000, requested_land: requested_land

      bid2.status.should == Bid.verbiage[:active]
      world.manager.broker.process_sale(bid)
      bid2.reload
      bid2.status.should == Bid.verbiage[:cancelled]
    end
  end

  context "solicited bid" do
    let!(:listing) { Factory.create :listing, megatile_grouping: offered_land, owner: seller }
    let!(:bid) { Bid.create! bidder: bidder, current_owner: seller, money: 1000, listing: listing }

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
        seller.balance.should == 2000
      end
    end

    context "with multiple listings" do
      let!(:offered_land2) { create :megatile_grouping, megatiles: [sellers_tile] }
      let!(:listing2) { Factory.create :listing, megatile_grouping: offered_land2, owner: seller }

      it "processes a bid for a listing and cancels the other listings" do
        listing2.status.should == Listing.verbiage[:active]
        world.manager.broker.process_sale(bid)
        listing2.reload
        listing2.status.should == Listing.verbiage[:cancelled]
      end
    end

    context "with multiple bids on a listing" do
      let!(:bid2) { Bid.create! bidder: bidder, current_owner: seller, money: 1000, listing: listing }

      it "processes a bid for a listing and cancels the other bids" do
        bid2.status.should == Bid.verbiage[:active]
        world.manager.broker.process_sale(bid)
        bid2.reload
        bid2.status.should == Bid.verbiage[:rejected]
      end
    end
  end
end
