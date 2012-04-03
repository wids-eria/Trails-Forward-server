class MegatilesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @world = World.find(params[:world_id])

    authorize! :do_things, @world

    # if @megatiles.count * @world.megatile_width > 1000
    x_min = params[:x_min].to_i
    x_max = params[:x_max].to_i
    y_min = params[:y_min].to_i
    y_max = params[:y_max].to_i

    if (x_max - x_min)*(y_max - y_min) > 2000
      render :status => :request_entity_too_large, :text => "Request too large"
      return
    end

    data = MegatileRegionCache.megatiles_in_region(@world.id, x_min: x_min, y_min: y_min, x_max: x_max, y_max: y_max)
    ret = "{\"megatiles\": #{data}}"

    respond_to do |format|
      format.json { render :text => ret, :content_type => 'application/json' }
    end
  end

  def show
    @megatile = Megatile.find(params[:id])
    authorize! :do_things, @megatile.world


    respond_to do |format|
      format.xml  { render_for_api :megatile_with_resources, :xml  => @megatile, :root => :megatile  }
      format.json { render_for_api :megatile_with_resources, :json => @megatile, :root => :megatile  }
    end
  end

  def appraise
    @megatile = Megatile.find(params[:id])
    authorize! :do_things, @megatile.world

    respond_to do |format|
      format.xml  { render_for_api :megatile_with_value, :xml  => @megatile, :root => :megatile  }
      format.json { render_for_api :megatile_with_value, :json => @megatile, :root => :megatile  }
    end

  end

  def appraise_list
    @megatiles = Megatile.find(params["megatiles"])

    # TODO check if we are allowed to do things to the list of megatiles
    @megatiles.each do |megatile|
      authorize! :do_things, megatile.world
    end

    respond_to do |format|
      format.xml  { render_for_api :megatiles_with_value, :xml  => @megatiles, :root => :megatiles  }
      format.json { render_for_api :megatiles_with_value, :json => @megatiles, :root => :megatiles  }
    end
  end
end
