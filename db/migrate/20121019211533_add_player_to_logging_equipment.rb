class AddPlayerToLoggingEquipment < ActiveRecord::Migration
  def change
    add_column :logging_equipments, :player_id, :integer
  end
end
