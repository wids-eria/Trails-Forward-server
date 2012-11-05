class RenameLoggingEquipmentTypeField < ActiveRecord::Migration
  def change
    # type is reserved :|
    rename_column :logging_equipment_templates, :type, :equipment_type
  end
end
