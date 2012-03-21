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

  it "accepts a bid with no listing on a tile with no listings" do
    bid = Bid.create! bidder: bidder, current_owner: seller, money: 1000, requested_land: requested_land
    bid.accept!

    world.manager.broker.process_sale(bid)
    # make sure its transfered. and money is too
    # break up into different its
    sellers_tile.reload
    sellers_tile.owner.should == bidder
    seller.reload
    seller.balance.should == 1100
  end

  it "accepts a bid with no listing on a tile with listings" do
    listing = Factory.create :listing, megatile_grouping: offered_land 
    bid = Bid.create! bidder: bidder, current_owner: seller, money: 100, requested_land: requested_land
    bid.accept!

    world.manager.broker.process_sale(bid)
    # make sure listings are canceled
  end
end
