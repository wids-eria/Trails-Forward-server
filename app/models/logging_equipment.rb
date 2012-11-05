class LoggingEquipment < ActiveRecord::Base
  acts_as_api

  scope :unowned, where(player_id: nil)
  scope :owned_by, lambda{|player| where(player_id: player.id)}

  belongs_to :logging_equipment_template
  belongs_to :world
  belongs_to :player

  validates :name, :equipment_type, :market_description, :presence => true
  validates :initial_cost, :operating_cost, :maintenance_cost, :presence => true
  validates :harvest_volume, :diameter_range_min, :diameter_range_max, :yarding_volume, :transport_volume, :presence => true
  validates :condition, :reliability, :decay_rate, :scrap_value, :presence => true
  validates :world_id, :presence => true

  validate :player_belongs_to_world

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

  api_accessible :logging_equipment_base do |template|
    template.add :id
    template.add :name
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

  private

  def self.between(min, max)
    min + (rand * (max - min))
  end

  def player_belongs_to_world
    if world.present? && player.present?
      errors.add(:player, 'must belong to world') if player.world_id != world.id
    end
  end
end
