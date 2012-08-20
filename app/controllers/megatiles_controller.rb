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

    data = MegatileRegionCache.megatiles_in_region(@world.id, x_min: x_min, y_min: y_min, x_max: x_max, y_max: y_max)
    ret = "{\"megatiles\": #{data[:json]}}"

    if stale?(:last_modified => data[:last_modified])
      respond_to do |format|
        format.json { render :text => ret, :content_type => 'application/json' }
      end
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


  def buy
    megatile = Megatile.find(params[:id])
    authorize! :do_things, megatile.world

    player = megatile.world.player_for_user(current_user)

    if megatile.owner.present?
      respond_to do |format|
        format.xml  { render  xml: { errors: ["Already owned"] }, status: :unprocessable_entity }
        format.json { render json: { errors: ["Already owned"] }, status: :unprocessable_entity }
      end
    else
      megatile.owner = player
      player.balance -= Megatile.cost

      begin
        ActiveRecord::Base.transaction do
          if megatile.save && player.save

            megatile.invalidate_cache

            respond_to do |format|
              format.xml  { head :ok }
              format.json { head :ok }
            end
          else
            raise ActiveRecord::RecordInvalid.new(player)
          end
        end
      rescue ActiveRecord::RecordInvalid
        respond_to do |format|
          format.xml  { render  xml: { errors: ["Not enough money"] }, status: :unprocessable_entity }
          format.json { render json: { errors: ["Not enough money"] }, status: :unprocessable_entity }
        end
      end
    end
  end
end
