class WorldPlayersController < ApplicationController
  def pine_sawtimber
    @world =  World.find(params[:id])
    @price = @world.pine_sawtimber_price
    
    respond_to do |format|
      format.json  { render :json  => {:price => @price, :unit => "board-foot"}  }
    end
  end

end
