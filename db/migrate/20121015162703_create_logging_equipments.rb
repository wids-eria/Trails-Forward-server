class CreateLoggingEquipments < ActiveRecord::Migration
  def change
    create_table :logging_equipments do |t|
      t.string :name
      t.string :equipment_type
      t.float :initial_cost
      t.float :operating_cost
      t.float :maintenance_cost
      t.float :harvest_volume
      t.integer :diameter_range_min
      t.integer :diameter_range_max
      t.float :yarding_volume
      t.float :transport_volume
      t.float :condition
      t.float :reliability
      t.float :decay_rate
      t.float :scrap_value

      t.timestamps
    end
  end
end
