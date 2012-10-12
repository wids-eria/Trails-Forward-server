class MessagesController < ApplicationController
  before_filter :authenticate_user!
  skip_authorization_check

  expose(:messages) { current_player.received_messages }
  expose(:message)
  expose(:world)
  expose(:current_player) { world.player_for_user(current_user) }

  respond_to :json


  def index
    respond_with messages
  end


  def show
    respond_with message
  end


  def create
    message.sender = current_player
    message.save

    respond_with message
  end


  def update
    message.update_attributes params[:message]

    respond_with message
  end


  def read
    message.read
    message.save

    respond_with message
  end


  def archive
    message.archive
    message.save

    respond_with message
  end

end
