require 'set'

class Broker

  TrumpedBid = "Another transaction affected the land included in this bid"
  TrumpedListing = "Another transaction affected the land included in this listing"

  attr_reader :world

  def initialize(world)
    @world = world
  end

  def process_sale(bid)
    if TrailsForwardWorld::Application.config.execute_sales_immediately
      execute_sale bid
    else
      execute_sale_deferred bid
    end
  end

  def execute_sale_deferred(bid)
    ActiveRecord::Base.transaction do
      lock_assets_for_bid bid
      reject_other_bids bid
      enqueue_bid_for_transfer bid
    end
  end

  def enqueue_bid_for_transfer bid
    TransferChangeRequest.create! world: @world, target: bid
  end

  # atomically processes a sale *immediately*, rejecting competing bids
  def execute_sale(bid)
    raise "Can't process a sale for an unaccepted bid" unless bid.status == Bid::Verbiage[:accepted]

    ActiveRecord::Base.transaction do
      lock_assets_for_bid bid

      transfer_assets bid
      reject_other_bids bid
      bid.execution_complete = true
      bid.save!
    end #transaction
  end

  def reject_other_bids(bid)
    if bid.listing  #this wasn't unsolicited
      bid.listing.bids.each do |bid_to_reject|
        reject_bid(bid_to_reject, "Other bid accepted") unless bid_to_reject == bid
      end
    end

    megatiles_purchased =  bid.requested_land.megatiles

    if bid.offered_land
      megatiles_paid = bid.offered_land.megatiles
      megatiles_affected = Set.new.union(megatiles_purchased).union(megatiles_paid)
    else
      megatiles_affected = megatiles_purchased
    end

    #cancel bids on other listings that contain megatiles purchased this bid
    #and cancel bids made on land *paid* as part of this transaction
    # then
    #revoke listings on land paid in this transaction
    #and revoke other listings that include purchased land
    megatiles_affected.each do |mt|
      mt.bids_on.each do |other_bid|
        cancel_bid(other_bid, TrumpedBid) unless other_bid == bid
      end

      mt.bids_offering.each do |other_bid|
        cancel_bid(other_bid, TrumpedBid) unless other_bid == bid
      end

      mt.listings.each do |other_listing|
        cancel_listing(other_listing, TrumpedListing) unless other_listing == bid.listing
      end
    end
  end #reject_other_bids

  def transfer_assets(bid)
    if bid.listing  #this wasn't unsolicited
      bid.listing.status = Listing::Verbiage[:sold]
      bid.listing.save!
      #any hooks to notify listing owner go here
    end

    #any hooks to notify buyer go here

    #I gotsta get paid
    bid.bidder.balance -= bid.money
    bid.bidder.save!

    bid.current_owner.balance += bid.money
    bid.current_owner.save!

    #transfer property
    if bid.offered_land
      bid.offered_land.megatiles.each do |mt|
        mt.owner = bid.current_owner
        mt.save!
      end
    end

    bid.requested_land.megatiles.each do |mt|
      mt.owner = bid.bidder
      mt.save!
    end

    bid.save!
  end

  def lock_assets_for_bid(bid)
    world = bid.bidder.world.lock!

    #If the above really slows things down, then we can tack on:
    #    unless ActiveRecord::Base.connection.adapter_name == 'MySQL'   #assumes InnoDB

    # Alas, we can't be more fine-grained than this because we can't
    # release a lock once we have it other than by ending the transaction
    # ideally we'd grab a world-level lock, then get more fine-grained locks on all related
    # megatile owners/bidders, then release the world-level lock.
    # I don't think there's a way to do this given MySQL/Rails pessimistic
    # locking semantics, at least while avoiding deadlock.
  end

  def reject_bid(rejected_bid, explanation)
    if bid.is_active?
      bid.status = Bid::Verbiage[:rejected]
      bid.rejection_reason = explanation
      #any hooks and such go here

      bid.save!
    end
  end

  def cancel_bid(cancelled_bid, explanation)
    if bid.is_active?
      bid.status = Bid::Verbiage[:cancelled]
      bid.rejection_reason = explanation
      #any hooks and such go here

      bid.save!
    end
  end

  def cancel_listing(listing, explanation)
    if listing.is_active?
      listing.status = Listing::Verbiage[:cancelled]
      #hooks go here

      listing.save!
    end
  end

end
