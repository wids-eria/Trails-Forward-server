class Contract < ActiveRecord::Base
  acts_as_api

  belongs_to :contract_template
  belongs_to :world
  belongs_to :player
  has_and_belongs_to_many :included_megatiles, :join_table => 'contract_included_megatiles', :association_foreign_key => :megatile_id, :class_name => 'Megatile'
  has_and_belongs_to_many :attached_megatiles, :join_table => 'contract_attached_megatiles', :association_foreign_key => :megatile_id, :class_name => 'Megatile'

  validates :world, presence: true
  validates :contract_template_id, presence: true

  def is_satisfied?
    raise "not implemented"
  end

  def deliver
    raise "not implemented"
  end

  def deliver!
    deliver and save!
  end

  api_accessible :base_contract do |template|
    template.add :id
    template.add :world_id
    template.add :player_id
    template.add :month_started
    template.add :month_ended
    template.add :ended
    template.add :successful
    template.add :on_time
    template.add :points_earned
    template.add :created_at
    template.add :updated_at
    template.add :attached_megatiles, template: :megatile_with_owner
    template.add :included_megatiles, template: :megatile_with_owner
    template.add 'contract_template.codename', :as => :codename
    template.add 'contract_template.company_id', :as => :company_id
    template.add 'contract_template.company.codename', :as => :company_codename
    template.add 'contract_template.includes_land', :as => :includes_land
    template.add 'contract_template.description', :as => :description
    template.add 'contract_template.deadline', :as => :delivery_window
    template.add 'contract_template.dollars', :as => :earnings
    template.add 'contract_template.role', :as => :role
    template.add 'contract_template.difficulty', :as => :difficulty
    template.add 'contract_template.points', :as => :points_offered
    template.add 'contract_template.points_required_to_unlock', :as => :points_required_to_unlock
  end


  api_accessible :lumberjack_contract, :extend => :base_contract do |template|
    template.add :volume_harvested_of_required_type, :as => :volume_harvested
    template.add 'contract_template.wood_type', :as => :kind
    template.add 'contract_template.volume_required', :as => :volume_needed

  end

  api_accessible :developer_contract, :extend => :base_contract do |template|
    template.add :volume_harvested_of_required_type, :as => :properties_built
    template.add 'contract_template.acres_added_required', :as => :acres_added_required
    template.add 'contract_template.acres_developed_required', :as => :properties_needed
    template.add 'contract_template.home_type', :as => :housing_type
  end
end
