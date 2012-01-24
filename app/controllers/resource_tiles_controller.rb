class ResourceTilesController < ApplicationController
  before_filter :authenticate_user!
  skip_authorization_check :only => :permitted_actions

  expose(:world) { World.find params[:world_id] }
  expose(:resource_tile) { ResourceTile.find params[:id] }

  expose(:resource_tiles) do
    if params[:resource_tile_ids]
      ResourceTile.find(params["resource_tile_ids"]).sort
    else
      ResourceTile.within_rectangle x: params[:x], y: params[:y], width: params[:width], height: params[:height]
    end
  end

  def permitted_actions
    respond_to do |format|
      player = world.player_for_user(current_user)

      resource_tiles.each do |tile|
        tile.set_permitted_actions_method(player)
      end
      format.xml  { render_for_api :resource, :xml  => resource_tiles, :root => :resource_tiles  }
      format.json { render_for_api :resource, :json => resource_tiles, :root => :resource_tiles  }
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
    a_ok = true
    resource_tiles.each do |tile|
      authorize! :clearcut, tile
      if not tile.can_clearcut?
        a_ok = false
      end
    end

    resource_tiles.each &:clearcut!

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

  def build_list
    # not yet implemented
  end
end
