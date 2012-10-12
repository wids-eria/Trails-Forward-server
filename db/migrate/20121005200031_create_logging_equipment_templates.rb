class CreateLoggingEquipmentTemplates < ActiveRecord::Migration
  def change
    create_table :logging_equipment_templates do |t|
      t.string :name
      t.string :type

      t.text :market_description

      # Costs
      t.integer :initial_cost_min
      t.integer :initial_cost_max

      t.integer :operating_cost_min
      t.integer :operating_cost_max

      t.integer :maintenance_cost_min
      t.integer :maintenance_cost_max


      # Harvesting
      t.integer :harvest_volume_min
      t.integer :harvest_volume_max

      t.integer :diameter_range_min
      t.integer :diameter_range_max

      t.integer :yarding_volume_min
      t.integer :yarding_volume_max

      t.integer :transport_volume_min
      t.integer :transport_volume_max


      # Condition
      t.integer :condition_min
      t.integer :condition_max

      t.integer :reliability_min
      t.integer :reliability_max

      t.integer :decay_rate_min
      t.integer :decay_rate_max

      t.integer :scrap_value_min
      t.integer :scrap_value_max

      t.timestamps
    end
  end
end
