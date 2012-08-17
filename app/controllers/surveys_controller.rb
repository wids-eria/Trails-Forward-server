class SurveysController < ApplicationController
  before_filter :authenticate_user!

  def index
    world = World.find(params[:world_id])
    megatile = world.megatiles.find(params[:megatile_id])
    authorize! :do_things, world

    player = megatile.world.player_for_user(current_user)

    @surveys = megatile.surveys.where(player_id: player.id)

    respond_to do |format|
      format.xml  { render_for_api :survey,  xml: @surveys }
      format.json { render_for_api :survey, json: @surveys }
    end
  end

  def create
    world = World.find(params[:world_id])
    megatile = world.megatiles.find(params[:megatile_id])
    authorize! :do_things, world

    player = megatile.world.player_for_user(current_user)

    @survey = Survey.of megatile: megatile, player: player

    player.balance -= 25

    begin
      ActiveRecord::Base.transaction do
        if @survey.save && player.save
          respond_to do |format|
            format.xml  { render_for_api :survey,  xml: @survey, status: :created }
            format.json { render_for_api :survey, json: @survey, status: :created }
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
