class ContractTemplate < ActiveRecord::Base
  acts_as_api

  belongs_to :company

  has_many :contracts

  validates :company_id, presence: true
  validates :codename, presence: true, uniqueness: true

  Possible_Roles = ["Conserver", "Developer", "Lumberjack"]
  validates :role, presence: true, inclusion: { in: Possible_Roles }

  Possible_Difficulties = ["easy", "medium", "hard", "professional"]
  validates :difficulty, presence: true, inclusion: { in: Possible_Difficulties }
  validates :points, presence: true, numericality: true
  validates :points_required_to_unlock, presence: true, numericality: true
  validates :dollars, presence: true, numericality: true

  Possible_Wood_Types = ["pole_timber", "saw_timber"]
  validate :valid_logging_contract?
  validate :valid_development_contract?

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

  def to_s
    codename
  end


  api_accessible :contract_template do |template|
    template.add :id
    template.add :role
    template.add :difficulty
    template.add :points_required_to_unlock
    template.add :points
    template.add :dollars
    template.add :deadline
    template.add :description
    template.add :includes_land
    template.add :volume_required
    template.add :wood_type
    template.add :acres_added_required
    template.add :acres_developed_required
    template.add :home_type
    template.add :company_id
    template.add :created_at
    template.add :updated_at
  end

end

