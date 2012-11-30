module LoggingEquipmentApi
  extend ActiveSupport::Concern
  included do
    api_accessible :logging_equipment_base do |template|
      template.add :id
      template.add :name
      template.add :player_id
      template.add :equipment_type
      template.add :market_description

      template.add :diameter_range_min
      template.add :diameter_range_max

      template.add :initial_cost
      template.add :operating_cost
      template.add :maintenance_cost

      template.add :harvest_volume
      template.add :yarding_volume
      template.add :transport_volume

      template.add :condition
      template.add :reliability
      template.add :decay_rate
      template.add :scrap_value
    end
  end
end

