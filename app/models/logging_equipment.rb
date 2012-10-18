class LoggingEquipment < ActiveRecord::Base
  belongs_to :logging_equipment_template

  def self.generate_from(template)
    equipment = self.new
    equipment.logging_equipment_template = template

    equipment.name = template.name
    equipment.equipment_type = template.equipment_type
    equipment.market_description = template.market_description

    equipment.diameter_range_min = template.diameter_range_min
    equipment.diameter_range_max = template.diameter_range_max

    equipment.initial_cost     = between(template.initial_cost_min,     template.initial_cost_max    )
    equipment.operating_cost   = between(template.operating_cost_min,   template.operating_cost_max  )
    equipment.maintenance_cost = between(template.maintenance_cost_min, template.maintenance_cost_max)

    equipment.harvest_volume   = between(template.harvest_volume_min,   template.harvest_volume_max  )
    equipment.yarding_volume   = between(template.yarding_volume_min,   template.yarding_volume_max  )
    equipment.transport_volume = between(template.transport_volume_min, template.transport_volume_max)

    equipment.condition        = between(template.condition_min,        template.condition_max       )
    equipment.reliability      = between(template.reliability_min,      template.reliability_max     )
    equipment.decay_rate       = between(template.decay_rate_min,       template.decay_rate_max      )
    equipment.scrap_value      = between(template.scrap_value_min,      template.scrap_value_max     )

    equipment
  end

  def self.between(min, max)
    min + (rand * (max - min))
  end
end
