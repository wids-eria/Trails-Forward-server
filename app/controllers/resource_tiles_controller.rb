class ResourceTilesController < ApplicationController
  before_filter :authenticate_user!

  def clearcut
    @resource_tile = ResourceTile.find params[:id]
    authorize! :clearcut, @resource_tile

    if @resource_tile.can_clearcut?
      @resource_tile.clearcut!
      respond_to do |format|
        format.xml  { render_for_api :resource, :xml  => @resource_tile, :root => :resource_tile  }
        format.json { render_for_api :resource, :json => @resource_tile, :root => :resource_tile  }
      end
    else
      respond_to do |format|
        format.json { render :status => :forbidden, :text => "Action illegal for this land" }
      end
    end
  end

  def bulldoze
    @resource_tile = ResourceTile.find(params[:id])
    authorize! :bulldoze, @resource_tile

    if @resource_tile.can_bulldoze?
      @resource_tile.bulldoze!
      respond_to do |format|
        format.xml  { render_for_api :resource, :xml  => @resource_tile, :root => :resource_tile  }
        format.json { render_for_api :resource, :json => @resource_tile, :root => :resource_tile  }
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
    @resource_tile = ResourceTile.find(params[:id])
    authorize! :do_things, @resource_tile.world

    respond_to do |format|
      format.xml  { render_for_api :resource, :xml  => @resource_tile, :root => :resource_tile  }
      format.json { render_for_api :resource, :json => @resource_tile, :root => :resource_tile  }
    end
  end


  def bulldoze_list
    @resource_tiles = ResourceTile.find(params["microtiles"])

    @resource_tiles.each do |resource_tile|
      authorize! :bulldoze, resource_tile
      if not resource_tile.can_bulldoze?
        respond_to do |format|
          format.json { render :status => :forbidden, :text => "Action illegal for this land" }
          return
        end
      end
    end

    @resource_tiles.each do |resource_tile|
      resource_tile.bulldoze!
    end

    respond_to do |format|
      format.xml  { render_for_api :resource, :xml  => @resource_tiles, :root => :resource_tiles  }
      format.json { render_for_api :resource, :json => @resource_tiles, :root => :resource_tiles  }
    end
  end


  def clearcut_list
    @resource_tiles = ResourceTile.find(params["microtiles"])

    @resource_tiles.each do |resource_tile|
      authorize! :clearcut, resource_tile
      if not resource_tile.can_clearcut?
        respond_to do |format|
          format.json { render :status => :forbidden, :text => "Action illegal for this land" }
          return
        end
      end
    end

    @resource_tiles.each do |resource_tile|
      resource_tile.clearcut!
    end

    respond_to do |format|
      format.xml  { render_for_api :resource, :xml  => @resource_tiles, :root => :resource_tiles  }
      format.json { render_for_api :resource, :json => @resource_tiles, :root => :resource_tiles  }
    end
  end

  def build_list
    # not yet implemented
  end
end
