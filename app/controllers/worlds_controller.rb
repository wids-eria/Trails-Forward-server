class WorldsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @worlds = World.all
    authorize! :index_worlds, World

    respond_to do |format|
      format.xml  { render_for_api :world_without_tiles, :xml  => @worlds, :root => :worlds  }
      format.json { render_for_api :world_without_tiles, :json => @worlds, :root => :worlds  }
      format.html
    end
  end

  def show
    @world = World.find(params[:id])
    authorize! :show_world, @world

    respond_to do |format|
      format.xml  { render_for_api :world_without_tiles, :xml  => @world, :root => :world  }
      format.json { render_for_api :world_without_tiles, :json => @world, :root => :world  }
    end
  end

  # def new
  #   @world = World.new
  #
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @world }
  #   end
  # end
  #
  # def edit
  #   @world = World.find(params[:id])
  # end
  #
  # def create
  #   @world = World.new(params[:world])
  #
  #   respond_to do |format|
  #     if @world.save
  #       format.html { redirect_to(@world, :notice => 'World was successfully created.') }
  #       format.xml  { render :xml => @world, :status => :created, :location => @world }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @world.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  #

  def update
    @world = World.find(params[:id])
    authorize! :update_world, @world

    respond_to do |format|
      if @world.update_attributes(params[:world])
        format.xml  { render_for_api :world_without_tiles, :xml  => @world }
        format.json { render_for_api :world_without_tiles, :json => @world }
      else
        format.xml  { render :xml  => @world.errors, :status => :unprocessable_entity }
        format.json { render :json => @world.errors, :status => :unprocessable_entity }
      end
    end
  end

  #
  # def destroy
  #   @world = World.find(params[:id])
  #   @world.destroy
  #
  #   respond_to do |format|
  #     format.html { redirect_to(worlds_url) }
  #     format.xml  { head :ok }
  #   end
  # end

  def turn_state
    world = World.find(params[:id])
    authorize! :show_world, world

    manager = WorldTurn.new world: world

    respond_to do |format|
      format.xml  { render  xml: {time_left: manager.time_left, state: world.turn_state} }
      format.json { render json: {time_left: manager.time_left, state: world.turn_state} }
    end
  end

  def turn
    world = World.find(params[:id])
    authorize! :show_world, world

    manager = WorldTurn.new world: world
    can_proceed = manager.can_process_turn?

    respond_to do |format|
      if can_proceed

        manager.turn

        if world.save
          format.xml  { render_for_api :world_without_tiles, :xml  => world }
          format.json { render_for_api :world_without_tiles, :json => world, :root => :world  }
        else
          format.xml  { render :xml  => world.errors, :status => :unprocessable_entity }
          format.json { render :json => world.errors, :status => :unprocessable_entity }
        end
      else
        format.xml  { render  xml: {can_proceed: false} }
        format.json { render json: {can_proceed: false} }
      end
    end
  end
end
