class HarvestResponder < ActionController::Responder # This can become a generic responder to replace respond_to
  def initialize(controller, resources, options={})
    super(controller, resources, options)
  end

  def display(resource, given_options={})
    controller.respond_to do |format|
      format.xml  { render  xml: resource } # status seems to work automagically without merging
      format.json { render json: resource }
    end
  end
end

class ResourceTilesController < ApplicationController
  respond_to :xml, :json
  self.responder = HarvestResponder

  before_filter :authenticate_user!
  skip_authorization_check :only => :permitted_actions

  expose(:world) { World.find params[:world_id] }
  expose(:resource_tile) { ResourceTile.find params[:id] }

  expose(:resource_tiles) do
    if params[:resource_tile_ids]
      tiles = ResourceTile.where(id: params["resource_tile_ids"])
      tiles = tiles.harvestable if @clearcut
      tiles
    else
      tiles = world.resource_tiles
      tiles = tiles.harvestable if @clearcut
      tiles.includes(:megatile => :owner).within_rectangle x_min: params[:x_min], y_min: params[:y_min], x_max: params[:x_max], y_max: params[:y_max]
    end
  end

  expose(:player) { world.player_for_user(current_user) }


  # FIXME no longer used as an information layer on the client side 1/5/12
  def permitted_actions
    respond_to do |format|
      resource_tiles.each do |tile|
        tile.set_permitted_actions_method(player)
      end
      format.xml  { render_for_api :resource_actions, :xml  => resource_tiles, :root => :resource_tiles  }
      format.json { render_for_api :resource_actions, :json => resource_tiles, :root => :resource_tiles  }
    end
  end


  # GET /world/:world_id/resource_tiles/1
  def show
    authorize! :do_things, resource_tile.world

    respond_to do |format|
      format.json { render_for_api :resource, :json => resource_tile, :root => :resource_tile  }
    end
  end


  def build
    authorize! :build, resource_tile
    construction_type = params[:type]

    if resource_tile.can_build?
      case construction_type
        when "single family"
          Craftsman.new.build_single_family_home! resource_tile
        when "vacation"
          Craftsman.new.build_vacation_home! resource_tile
        when "apartment"
          Craftsman.new.build_apartment! resource_tile
        else
          raise "Unknown build type requested!"
      end
      respond_to do |format|
        format.json { render_for_api :resource, :json => resource_tile, :root => :resource_tile  }
      end
    else
      respond_to do |format|
        format.json { render :status => :forbidden, :text => "Action illegal for this land" }
      end
    end
  end #build


  def build_outpost
    authorize! :build_outpost, resource_tile
    
    tiles = resource_tile.neighbors(20)
    tiles.update_all(:can_be_surveyed => true)

    bounding_box = { x_min: tiles.collect(&:x).min, x_max: tiles.collect(&:x).max, y_min: tiles.collect(&:y).min, y_max: tiles.collect(&:y).max }

    tiles.collect(&:megatile).uniq.each(&:invalidate_cache)

    resource_tile.reload
    resource_tile.outpost = true

    if resource_tile.save      
      respond_to do |format|
        format.xml  { render_for_api :resource, :xml  => resource_tiles, :root => :resource_tiles  }
        format.json { render_for_api :resource, :json => resource_tiles, :root => :resource_tiles  }
      end
    else
      format.xml  { render :xml =>  resource_tile.errors, :status => :unprocessable_entity }
      format.json { render :json => resource_tile.errors, :status => :unprocessable_entity }
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
    resource_tiles.each do |tile|
      authorize! :harvest, tile
    end

    usable_tiles = resource_tiles.select(&:can_harvest?)
    player.balance -= Pricing.clearcut_cost(usable_tiles)

    begin
      ActiveRecord::Base.transaction do
        player.save!

        # Do the cuts
        results = usable_tiles.collect(&:clearcut!)

        # Update the market for viable tiles
        usable_tiles.each_with_index do |tile, index|
          tile.update_market! results[index]
        end

        respond_with results_hash(results, usable_tiles)
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_with({errors: ["Transaction Failed: #{e.message}"]}, status: :unprocessable_entity)
    end
  end


  def build_list
    raise 'not yet implemented'
  end


  def diameter_limit_cut_list
    authorize! :harvest, ResourceTile

    results = resource_tiles.collect do |tile|
      tile.diameter_limit_cut!(above: params[:above], below: params[:below])
    end

    summary = results_hash(results, resource_tiles)

    respond_to do |format|
      format.xml  { render  xml: summary }
      format.json { render json: summary }
    end
  end


  def partial_selection_cut_list
    authorize! :harvest, ResourceTile

    results = resource_tiles.collect do |tile|
      tile.partial_selection_cut!(qratio: params[:qratio], target_basal_area: params[:target_basal_area])
    end

    summary = results_hash(results, resource_tiles)

    respond_to do |format|
      format.xml  { render  xml: summary }
      format.json { render json: summary }
    end
  end


  private

  def results_hash(results, resource_tiles)
    poletimber_value  = results.collect{|result| result[:poletimber_value ]}.sum
    poletimber_volume = results.collect{|result| result[:poletimber_volume]}.sum
    sawtimber_value   = results.collect{|result| result[:sawtimber_value  ]}.sum
    sawtimber_volume  = results.collect{|result| result[:sawtimber_volume ]}.sum

    { poletimber_value: poletimber_value, poletimber_volume: poletimber_volume,
       sawtimber_value: sawtimber_value,   sawtimber_volume: sawtimber_volume,
        resource_tiles: resource_tiles.as_api_response(:resource)
    }
  end
end
