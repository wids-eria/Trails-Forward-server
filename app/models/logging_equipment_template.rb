class LoggingEquipmentTemplate < ActiveRecord::Base
      validates :name, :equipment_type, :market_description, :presence => true
      validates :initial_cost_min, :initial_cost_max, :operating_cost_min, :operating_cost_max, :maintenance_cost_min, :maintenance_cost_max, :presence => true
      validates :harvest_volume_min, :harvest_volume_max, :diameter_range_min, :diameter_range_max, :yarding_volume_min, :yarding_volume_max, :transport_volume_min, :transport_volume_max, :presence => true
      validates :condition_min, :condition_max, :reliability_min, :reliability_max, :decay_rate_min, :decay_rate_max, :scrap_value_min, :scrap_value_max, :presence => true
end
