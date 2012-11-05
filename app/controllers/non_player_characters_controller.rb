class NonPlayerCharactersController < ApplicationController
  skip_authorization_check
  expose(:world)
  expose(:non_player_characters) { NonPlayerCharacter.all }
  expose(:non_player_character)

  respond_to :json, :html


  def index
    respond_with non_player_characters
  end

  def show
    respond_with non_player_character
  end

  def create
    if non_player_character.save
      flash[:notice] = "Character Created"
      respond_with non_player_character, notice: 'Created!', location: non_player_characters_path(world.id)
    else
      render :new
    end
  end

  def update
    flash[:notice] = "Character Updated" if non_player_character.update_attributes (params[:non_player_character]||params[:company]||params[:person])

    respond_with non_player_character, location: non_player_characters_path
  end
end
