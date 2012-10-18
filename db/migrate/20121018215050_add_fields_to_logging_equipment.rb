class AddFieldsToLoggingEquipment < ActiveRecord::Migration
  def change
    add_column :logging_equipments, :market_description, :text
    add_column :logging_equipments, :logging_equipment_id, :integer
  end
end
