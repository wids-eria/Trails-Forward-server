class LoggingEquipmentController < ApplicationController
  skip_authorization_check
  expose(:logging_equipment_template)
  expose(:logging_equipment_list) { LoggingEquipment.scoped }
  expose(:logging_equipment) do
    if params[:id]
      LoggingEquipment.find params[:id]
    else
      if logging_equipment_template.valid?
        LoggingEquipment.generate_from(logging_equipment_template)
      else
        LoggingEquipment.new params[:logging_equipment]
      end
    end
  end

  respond_to :json, :html


  def index
    respond_with logging_equipment_list
  end


  def show
    respond_with logging_equipment
  end


  def create
    flash[:notice] = "Equipment Created" if logging_equipment.save

    respond_with logging_equipment, notice: 'Created!', location: logging_equipment_index_path
  end


  def update
    flash[:notice] = "Equipment Updated" if logging_equipment.update_attributes params[:logging_equipment]

    respond_with logging_equipment, location: logging_equipment_index_path
  end
end
