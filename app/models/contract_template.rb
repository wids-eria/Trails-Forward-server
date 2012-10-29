class ContractTemplate < ActiveRecord::Base
  belongs_to :world
  belongs_to :company

  validates :world_id, presence: true
  validates :company_id, presence: true
  validates :codename, presence: true, uniqueness: {scope: :world_id}

  Possible_Roles = ["all", "Conserver", "Developer", "Lumberjack"]
  validates :role, presence: true, inclusion: { in: Possible_Roles }

  Possible_Difficulties = ["easy", "medium", "hard", "professional"]
  validates :difficulty, presence: true, inclusion: { in: Possible_Difficulties }
  validates :points, presence: true, numericality: true
  validates :dollars, presence: true, numericality: true

  Possible_Wood_Types = ["pole_timber", "saw_timber"]
  validate :valid_logging_contract?
  validate :valid_development_contract?
  validate :associated_company_is_in_this_world

  def valid_logging_contract?
    if ["any", "Lumberjack"].include? role
      errors.add(:volume_required, "invalid required volume") unless volume_required != nil and volume_required > 0
      errors.add(:wood_type, "invalid wood type") unless [nil, "saw_timber", "pole_timber"].include? wood_type
    else
      errors.add(:volume_required, "non-logging contracts should not specify volume") unless [0, nil].include? volume_required
      errors.add(:wood_type, "non-logging contracts should not specify wood type") unless [nil, ""].include? wood_type
    end
  end

  def valid_development_contract?
    if ["any", "Developer"].include? role
      errors.add(:acres_added_required, "must be numeric and >= 0") unless acres_added_required != nil and acres_added_required >= 0
      errors.add(:acres_developed_required, "must be numeric and >= 0") unless acres_developed_required != nil and acres_developed_required >= 0
      errors.add(:home_type, "must be one of #{LandTile::HomeTypes}") unless LandTile::HomeTypes.include? home_type
    else
      true
    end
  end

  def associated_company_is_in_this_world
    errors.add(:company, "must be in this same world") unless company.world_id = world_id
  end

  def to_s
    "World #{world_id} - #{codename}"
  end
end
