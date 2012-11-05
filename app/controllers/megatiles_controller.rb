require 'time'

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
    coordinate_box = { :x_min => x_min, :x_max => x_max, :y_min => y_min, :y_max => y_max  }

    data = Megatile.in_region @world.id, coordinate_box

    if defined? request.env['HTTP_IF_MODIFIED_SINCE'] and request.env['HTTP_IF_MODIFIED_SINCE'] != nil
      modified_since = Time.rfc2822 request.env['HTTP_IF_MODIFIED_SINCE']
      #puts "**** HTTP_IF_MODIFIED_SINCE = #{modified_since.inspect}. Class = #{modified_since.class}"
      data = data.where('updated_at > ?', modified_since)
    end
    
    ret = data.map do |mt|
      {:id => mt.id, :x => mt.x, :y => mt.y, :updated_at => mt.updated_at.rfc2822} 
    end
    
    #puts "megatile index (#{request.env['HTTP_IF_MODIFIED_SINCE']} *** #{params.inspect}) ====> #{ret.inspect}"
    
    if ret and ret.count > 0 
      respond_to do |format|
        format.json { render :json => {:megatiles => ret}, :content_type => 'application/json' }
      end
    else
      render :nothing => true, :status => 304
    end
  end

  def show
    @megatile = Megatile.find(params[:id])
    authorize! :do_things, @megatile.world
    
    if stale?(:last_modified => @megatile.updated_at)
      respond_to do |format|
        format.xml  { render_for_api :megatile_with_resources, :xml  => @megatile, :root => :megatile  }
        format.json { render_for_api :megatile_with_resources, :json => @megatile, :root => :megatile  }
      end
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
          megatile.save!
          player.save!
        end

        megatile.invalidate_cache

        # FIXME this is quick solution to make client side tile update
        # vs manually editing the tile in unity - for Mark 1/5/12
        respond_to do |format|
          format.xml  { render_for_api :megatile_with_resources, :xml  => megatile, :root => :megatile  }
          format.json { render_for_api :megatile_with_resources, :json => megatile, :root => :megatile  }
        end
      rescue ActiveRecord::RecordInvalid
        respond_to do |format|
          format.xml  { render  xml: { errors: ["Transaction Failed"] }, status: :unprocessable_entity }
          format.json { render json: { errors: ["Transaction Failed"] }, status: :unprocessable_entity }
        end
      end
    end
  end
end
