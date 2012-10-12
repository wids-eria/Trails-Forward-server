class LoggingEquipmentTemplatesController < ApplicationController
  skip_authorization_check
  expose(:logging_equipment_templates) { LoggingEquipmentTemplate }
  expose(:logging_equipment_template)

  respond_to :json, :html


  def index
    respond_with logging_equipment_templates
  end


  def show
    respond_with logging_equipment_template
  end


  def create
    logging_equipment_template.save

    respond_with logging_equipment_template
  end


  def update
    logging_equipment_template.update_attributes params[:logging_equipment_template]

    respond_with logging_equipment_template
  end
end
