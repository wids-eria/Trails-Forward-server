class MyPlayersController < ApplicationController
  responds_to :html

  def index
    @players = current_user.players
    respond_with @players
  end

  def create
    @player = 

  end

  def new

  end

  def edit

  end

  def update

  end

  def destroy

  end
end
