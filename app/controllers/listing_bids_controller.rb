class ListingBidsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_listing_world_and_player

  def create
    authorize! :bid, @listing

    @bid = Bid.new do |b|
      b.bidder = @player
      b.money = params[:money]
      b.listing = @listing
    end

    if @bid.save
      respond_to do |format|
        format.json  { render_for_api :bid_private, :json => @bid, :root => :bid  }
        format.xml  { render_for_api :bid_private, :xml  => @bid, :root => :bid  }
      end
    else
      respond_to do |format|
        format.json  { render :json => @bid.errors, :status => :unprocessable_entity }
        format.xml  { render :xml => @bid.errors, :status => :unprocessable_entity }
      end
    end
  end

  def index
    authorize! :see_bids, @listing
    @bids = @listing.bids_on.to_a

    respond_to do |format|
      format.json  { render_for_api :bid_private, :json => @bids, :root => :bids  }
      format.xml  { render_for_api :bid_private, :xml  => @bids, :root => :bids  }
    end
  end

  def accept
    @bid = Bid.find(params[:id])
    authorize! :accept_bid, @bid

    @bid.accept!

    @world.manager.broker.process_sale(@bid)

    respond_to do |format|
      format.json  { render_for_api :bid_private, :json => @bid, :root => :bids  }
      format.xml  { render_for_api :bid_private, :xml  => @bid, :root => :bids  }
    end
  end

  private

  def find_listing_world_and_player
    @listing = Listing.find params[:listing_id]
    @world = @listing.world
    @player = @world.player_for_user current_user
  end

end
