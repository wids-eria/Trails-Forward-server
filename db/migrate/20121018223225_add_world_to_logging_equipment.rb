class AddWorldToLoggingEquipment < ActiveRecord::Migration
  def change
    add_column :logging_equipments, :world_id, :integer
  end
end
