class LoggingEquipmentTemplatesController < ApplicationController
  skip_authorization_check
  expose(:logging_equipment_templates) { LoggingEquipmentTemplate.scoped }
  expose(:logging_equipment_template)

  respond_to :json, :html


  def index
    respond_with logging_equipment_templates
  end


  def show
    respond_with logging_equipment_template
  end


  def create
    flash[:notice] = "Template Created" if logging_equipment_template.save

    respond_with logging_equipment_template, notice: 'Created!', location: logging_equipment_templates_path
  end


  def update
    flash[:notice] = "Template Updated" if logging_equipment_template.update_attributes params[:logging_equipment_template]

    respond_with logging_equipment_template, location: logging_equipment_templates_path
  end
end
