class BidsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @megatile = Megatile.find(params[:megatile_id])
    @world = @megatile.world
    @player = @world.player_for_user current_user

    authorize! :bid, @megatile

    @megatile_grouping = MegatileGrouping.create
    @megatile_grouping.megatiles << @megatile

    @bid = Bid.new do |b|
      b.bidder = @player
      b.current_owner = @megatile.owner
      b.money = params[:money]
      b.requested_land = @megatile_grouping
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
      @megatile_grouping.destroy
    end
  end

  def index
    @megatile = Megatile.find(params[:megatile_id])
    @world = @megatile.world
    @player = @world.player_for_user current_user

    authorize! :see_bids, @megatile
    @bids = @megatile.bids_on.to_a

    respond_to do |format|
      format.json  { render_for_api :bid_private, :json => @bids, :root => :bids  }
      format.xml  { render_for_api :bid_private, :xml  => @bids, :root => :bids  }
    end
  end

  def accept
    @bid = Bid.find(params[:bid_id])
    @megatile = Megatile.find(params[:megatile_id])
    @world = @megatile.world
    @player = @world.player_for_user current_user

    authorize! :accept_bid, @bid

    @bid.status = Bid::Verbiage[:accepted]
    @bid.save!

    @world.manager.broker.process_sale(@bid)

    respond_to do |format|
      format.json  { render_for_api :bid_private, :json => @bid, :root => :bids  }
      format.xml  { render_for_api :bid_private, :xml  => @bid, :root => :bids  }
    end
  end

end
