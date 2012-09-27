class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_world
  skip_authorization_check

  respond_to :json

  def index
    messages = current_player.received_messages.all

    respond_to do |format|
      format.json { render json: messages }
    end
  end


  def show
    message = Message.find params[:id]

    respond_to do |format|
      format.json { render json: message }
    end
  end


  def create
    message = Message.new params[:message]
    message.sender = current_player

    respond_to do |format|
      if message.save
        format.json { render json: message, status: :created, location: [world, message] }
      else
        format.json { render json: message.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    message = Message.find params[:id]

    respond_to do |format|
      if message.update_attributes params[:message]
        format.json { render json: message, status: :created, location: [world, message] }
      else
        format.json { render json: message.errors, status: :unprocessable_entity }
      end
    end
  end


  def read
    message = Message.find params[:id]
    message.read

    respond_to do |format|
      if message.save
        format.json { render json: message, status: :created, location: [world, message] }
      else
        format.json { render json: message.errors, status: :unprocessable_entity }
      end
    end
  end


  def archive
    message = Message.find(params[:id])
    message.archive

    respond_to do |format|
      if message.save
        format.json { render json: message, status: :created, location: [world, message] }
      else
        format.json { render json: message.errors, status: :unprocessable_entity }
      end
    end
  end


  private

  def find_world
    @world = World.find(params[:world_id])
  end

  def world
    @world
  end

  def current_player
    @current_player ||= world.player_for_user(current_user)
  end
end
