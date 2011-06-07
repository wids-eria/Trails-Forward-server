class ResourceTilesController < ApplicationController
  before_filter :authenticate_user!
  

  def clearcut
    @resource_tile = ResourceTile.find params[:id]
    authorize! :clearcut, @resource_tile
    
    if @resource_tile.can_be_clearcut?
      @resource_tile.clearcut!
      respond_to do |format|
        format.xml  { render_for_api :resource, :xml  => @resource_tile, :root => :resource_tile  }
        format.json { render_for_api :resource, :json => @resource_tile, :root => :resource_tile  }
      end
    else
      respond_to do |format|
        render :status => :forbidden, :text => "Action illegal for this land"
      end
    end 
  end #def clearcut


  def bulldoze
    @resource_tile = ResourceTile.find(params[:id])
    authorize! :bulldoze, @resource_tile

    if @resource_tile.can_be_bulldozed?
      @resource_tile.bulldoze!
      respond_to do |format|
        format.xml  { render_for_api :resource, :xml  => @resource_tile, :root => :resource_tile  }
        format.json { render_for_api :resource, :json => @resource_tile, :root => :resource_tile  }
      end
    else
      respond_to do |format|
        render :status => :forbidden, :text => "Action illegal for this land"
      end  
    end
  end
  
  def build
    #not yet implemented
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

end
