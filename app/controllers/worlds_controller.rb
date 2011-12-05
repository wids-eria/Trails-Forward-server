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
  # def update
  #   @world = World.find(params[:id])
  #
  #   respond_to do |format|
  #     if @world.update_attributes(params[:world])
  #       format.html { redirect_to(@world, :notice => 'World was successfully updated.') }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @world.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
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
end
