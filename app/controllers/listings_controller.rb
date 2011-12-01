class ListingsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @world = World.find(params[:world_id], :include => [:players])
    authorize! :index_listings, @world

    @listings = Listing.where(:owner_id => @world.players)
    if params[:active_only]
      @listings = @listings.where(:status => Listing::Verbiage[:active])
    end

    respond_to do |format|
      format.json  { render_for_api :listing, :json => @listings, :root => :listings  }
      format.xml   { render_for_api :listing, :xml  => @listings, :root => :listings  }
    end
  end

  def index_active
    # @world = World.find(params[:world_id], :include => [:players])
    # authorize! :index_listings, @world
    params[:active_only] = true
    index
  end

  def create
    @world = World.find params[:world_id]
    authorize! :list_megatiles_for_sale, @world

    mtg = MegatileGrouping.create
    params["megatiles"].each do |mt_id|
      megatile = Megatile.find mt_id
      if can? :list_for_sale, megatile
        mtg.megatiles << megatile
      else
        return render :nothing => true, :status => :forbidden
      end
    end

    @listing = Listing.new do |l|
      l.owner = @world.player_for_user current_user
      l.price = params[:price]
      l.megatile_grouping = mtg
    end

    if @listing.save
      respond_to do |format|
        format.json  { render_for_api :listing, :json => @listing, :root => :listing  }
        format.xml   { render_for_api :listing, :xml  => @listing, :root => :listing  }
      end
    else
      respond_to do |format|
        format.json  { render :json => @listing.errors, :status => :not_acceptable  }
        format.xml   { render :xml => @listing.errors, :status => :not_acceptable  }
      end
      mtg.destroy
    end
  end

end
