class ResourceTilesController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_authorization_check :only => :permitted_actions

  expose(:world) { World.find params[:world_id] }
  expose(:resource_tile) { ResourceTile.find params[:id] }

  expose(:resource_tiles) do
    if params[:resource_tile_ids]
      ResourceTile.find(params["resource_tile_ids"]).sort
    else
      world.resource_tiles.includes(:megatile => :owner).within_rectangle x_min: params[:x_min], y_min: params[:y_min], x_max: params[:x_max], y_max: params[:y_max]
    end
  end

  def permitted_actions
    respond_to do |format|
      player = world.player_for_user(current_user)

      resource_tiles.each do |tile|
        tile.set_permitted_actions_method(player)
      end
      format.xml  { render_for_api :resource_actions, :xml  => resource_tiles, :root => :resource_tiles  }
      format.json { render_for_api :resource_actions, :json => resource_tiles, :root => :resource_tiles  }
    end
  end

  def clearcut
    authorize! :clearcut, resource_tile

    if resource_tile.can_clearcut?
      resource_tile.clearcut!
      respond_to do |format|
        format.xml  { render_for_api :resource, :xml  => resource_tile, :root => :resource_tile  }
        format.json { render_for_api :resource, :json => resource_tile, :root => :resource_tile  }
      end
    else
      respond_to do |format|
        format.json { render :status => :forbidden, :text => "Action illegal for this land" }
      end
    end
  end

  def bulldoze
    authorize! :bulldoze, resource_tile

    if resource_tile.can_bulldoze?
      resource_tile.bulldoze!
      respond_to do |format|
        format.xml  { render_for_api :resource, :xml  => resource_tile, :root => :resource_tile  }
        format.json { render_for_api :resource, :json => resource_tile, :root => :resource_tile  }
      end
    else
      respond_to do |format|
        format.json { render :status => :forbidden, :text => "Action illegal for this land" }
      end
    end
  end

  def build
    # not yet implemented
  end

  # GET /world/:world_id/resource_tiles/1
  def show
    authorize! :do_things, resource_tile.world

    respond_to do |format|
      format.xml  { render_for_api :resource, :xml  => resource_tile, :root => :resource_tile  }
      format.json { render_for_api :resource, :json => resource_tile, :root => :resource_tile  }
    end
  end

  def update
    authorize! :god_mode, resource_tile, params[:god_mode]

    respond_to do |format|
      if resource_tile.update_attributes(params[:resource_tile])
        format.xml  { render_for_api :resource, :xml  => resource_tile, :root => :resource_tile  }
        format.json { render_for_api :resource, :json => resource_tile, :root => :resource_tile  }
      else
        format.xml  { render :xml =>  resource_tile.errors, :status => :unprocessable_entity }
        format.json { render :json => resource_tile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def build_outpost
    authorize! :build_outpost, resource_tile
    resource_tile.outpost = true
    resource_tile.save!
    
    tiles = resource_tile.neighbors 20
    tiles.each do |rt|
      if rt.class == LandTile 
        rt.can_be_surveyed = true
        rt.save!
      end
    end
    respond_to do |format|
      format.xml  { render_for_api :resource, :xml  => resource_tiles, :root => :tiles  }
      format.json { render_for_api :resource, :json => resource_tiles, :root => :tiles  }
    end
  end


  # TODO move the double logic into cancan, so it calls tiles can_bulldoze?
  def bulldoze_list
    a_ok = true
    resource_tiles.each do |tile|
      authorize! :bulldoze, tile
      if not tile.can_bulldoze?
        a_ok = false
      end
    end

    respond_to do |format|
      if not a_ok
        format.json { render :status => :forbidden, :json => {:text => "Action illegal for this land" }}
      else
        resource_tiles.each &:bulldoze!

        format.xml  { render_for_api :resource, :xml  => resource_tiles, :root => :resource_tiles  }
        format.json { render_for_api :resource, :json => resource_tiles, :root => :resource_tiles  }
      end
    end
  end

  def clearcut_list
    authorize! :harvest, ResourceTile

    respond_to do |format|
      results = resource_tiles.collect do |tile|
        tile.clearcut!
      end

      poletimber_value  = results.collect{|results| results[:poletimber_value]}.sum
      poletimber_volume = results.collect{|results| results[:poletimber_volume]}.sum
      sawtimber_value  = results.collect{|results| results[:sawtimber_value]}.sum
      sawtimber_volume = results.collect{|results| results[:sawtimber_volume]}.sum

      sum = {poletimber_value: poletimber_value, poletimber_volume: poletimber_volume, sawtimber_value: sawtimber_value, sawtimber_volume: sawtimber_volume}

      format.xml  { render xml: sum  }
      format.json { render json: sum }
    end
  end

  def build_list
    # not yet implemented
  end

  def diameter_limit_cut_list
    authorize! :harvest, ResourceTile

    results = resource_tiles.collect do |tile|
      tile.diameter_limit_cut!(above: params[:above], below: params[:below])
    end

    poletimber_value  = results.collect{|results| results[:poletimber_value]}.sum
    poletimber_volume = results.collect{|results| results[:poletimber_volume]}.sum
    sawtimber_value  = results.collect{|results| results[:sawtimber_value]}.sum
    sawtimber_volume = results.collect{|results| results[:sawtimber_volume]}.sum

    sum = {poletimber_value: poletimber_value, poletimber_volume: poletimber_volume, sawtimber_value: sawtimber_value, sawtimber_volume: sawtimber_volume}

    respond_to do |format|
      format.xml  { render xml: sum  }
      format.json { render json: sum }
    end
  end

  def partial_selection_cut_list
    authorize! :harvest, ResourceTile

    results = resource_tiles.collect do |tile|
      tile.partial_selection_cut!(qratio: params[:qratio], target_basal_area: params[:target_basal_area])
    end

    poletimber_value  = results.collect{|results| results[:poletimber_value]}.sum
    poletimber_volume = results.collect{|results| results[:poletimber_volume]}.sum
    sawtimber_value  = results.collect{|results| results[:sawtimber_value]}.sum
    sawtimber_volume = results.collect{|results| results[:sawtimber_volume]}.sum

    sum = {poletimber_value: poletimber_value, poletimber_volume: poletimber_volume, sawtimber_value: sawtimber_value, sawtimber_volume: sawtimber_volume}

    respond_to do |format|
      format.xml  { render xml: sum  }
      format.json { render json: sum }
    end
  end
end
