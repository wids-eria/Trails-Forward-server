class Player < ActiveRecord::Base
  acts_as_api

  serialize :quests, Hash

  def self.default_balance
    1000
  end

  attr_accessible :name, :user, :world, :balance, :pending_balance, :quest_points, :quests

  has_many :megatiles, :inverse_of => :owner, :foreign_key => 'owner_id'
  has_many :resource_tiles, :through => :megatiles
  belongs_to :world
  belongs_to :user
  validates_presence_of :user
  validates :world_id, :presence => true, :uniqueness => {:scope => :user_id}
  validates :balance, presence: true, numericality: {only_integer: true}

  has_many :bids_placed, :class_name => 'Bid', :inverse_of => :bidder, :foreign_key => 'bidder_id'
  has_many :bids_received, :class_name => 'Bid', :inverse_of => :current_owner, :foreign_key => 'current_owner_id'

  has_many :sent_messages, :class_name => 'Message', :inverse_of => :sender, :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => 'Message', :inverse_of => :recipient, :foreign_key => 'recipient_id'

  has_many :contracts
  has_many :contract_templates, :through => :contracts

  def selection_name
    "#{self.name}, world:#{world.id} #{world.name.truncate(15)}"
  end

  def contract_points
    contracts.map { |contract| contract.points_earned}.sum
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

  def used_too_much_time?
    time_remaining_this_turn < 0
  end

  api_accessible :id_and_name do |template|
    template.add :id
    template.add 'user.name', :as => :name
    template.add 'user.id', :as => :user_id
    template.add :type
    template.add :world_id
    template.add 'world.name', :as => :world_name
  end

  api_accessible :player_public, :extend => :id_and_name do |template|
    # template.add :megatiles, :template => :id_and_name
  end

  api_accessible :player_private, :extend => :player_public do |template|
    template.add :balance
    template.add :pending_balance
    template.add :quest_points
    template.add :quests
  end

  api_accessible :player_private_with_megatiles, :extend => :player_private do |template|
    template.add :megatiles, :template => :id_and_name
  end

  api_accessible :player_public_with_megatiles, :extend => :player_public do |template|
    template.add :megatiles, :template => :id_and_name
  end



end
