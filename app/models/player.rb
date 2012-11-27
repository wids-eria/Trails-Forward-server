class Player < ActiveRecord::Base
  acts_as_api
  include PlayerApi

  serialize :quests, Hash

  def self.default_balance
    50000
  end

  def self.default_time_remaining
    48 # In months.
  end

  attr_accessible :name, :user, :world, :balance, :pending_balance, :time_remaining_this_turn, :quest_points, :quests


  # ASSOCIATIONS #########################
  #

  has_many :megatiles, :inverse_of => :owner, :foreign_key => 'owner_id'
  has_many :resource_tiles, :through => :megatiles
  belongs_to :world
  belongs_to :user

  has_many :bids_placed, :class_name => 'Bid', :inverse_of => :bidder, :foreign_key => 'bidder_id'
  has_many :bids_received, :class_name => 'Bid', :inverse_of => :current_owner, :foreign_key => 'current_owner_id'

  has_many :sent_messages, :class_name => 'Message', :inverse_of => :sender, :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => 'Message', :inverse_of => :recipient, :foreign_key => 'recipient_id'

  has_many :contracts
  has_many :contract_templates, :through => :contracts

  has_many :logging_equipment


  # VALIDATIONS ##########################
  #

  validates_presence_of :user
  validates :world_id, :presence => true, :uniqueness => {:scope => :user_id}
  validates :balance, presence: true, numericality: {only_integer: true}


  # CALLBACKS ############################
  #

  before_create :create_default_sawyer_crew_logging_equipment



  def selection_name
    "#{self.name}, world:#{world.id} #{world.name.truncate(15)}"
  end

  def contract_points
    contracts.map { |contract| contract.points_earned || 0 }.sum
  end

  def available_contracts
    Contract.find(:all,
                  :conditions => ['player_id is NULL AND contract_templates.points_required_to_unlock >= ? AND contract_templates.role = ? ',  self.contract_points, self.type],
                  :joins => [:contract_template])
  end

  def company_points company
    contracts = Contract.find(:all, :conditions => ['contracts.player_id = ? AND contract_templates.company_id = ?', self.id, company.id],
      :joins => [:contract_template])
    contracts.map { |contract| contract.points_earned}.sum
  end

  delegate :name, to: :user, allow_nil: true


  # EQUIPMENT ############################
  #

  def create_default_sawyer_crew_logging_equipment
    unless self.logging_equipment.detect{|equipment| equipment.name == "Sawyer Crew"} # atomic
      crew = LoggingEquipment.sawyer_crew
      if crew
        crew.player = self
        crew.world = self.world
        self.logging_equipment << crew
      end
    end
  end

end
