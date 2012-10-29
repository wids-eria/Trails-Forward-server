class WorldLoggingEquipmentController < ApplicationController
  self.responder = ActsAsApi::Responder

  skip_authorization_check

  expose(:world)
  expose(:player) { world.player_for_user(current_user) }
  expose(:logging_equipment_list) { world.logging_equipment.unowned }
  expose(:logging_equipment)

  respond_to :json, :xml

  def index
    respond_with logging_equipment_list, :api_template => :logging_equipment_base, :root => :logging_equipment_list
  end

  def buy
    logging_equipment.player = player
    player.balance -= logging_equipment.initial_cost.to_i

    player.save!
    logging_equipment.save!

    respond_with logging_equipment
  end
end
