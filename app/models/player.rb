class Player < ActiveRecord::Base
  acts_as_api

  def self.default_balance
    1000
  end

  attr_accessible :name, :user, :world, :balance, :pending_balance

  validates_uniqueness_of :user_id, :scope => :world_id
  validates_uniqueness_of :type,    :scope => :world_id

  has_many :megatiles, :inverse_of => :owner, :foreign_key => 'owner_id'
  has_many :resource_tiles, :through => :megatiles
  belongs_to :world
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :world
  validates_numericality_of :balance
  validates_presence_of :balance

  has_many :bids_placed, :class_name => 'Bid', :inverse_of => :bidder, :foreign_key => 'bidder_id'
  has_many :bids_received, :class_name => 'Bid', :inverse_of => :current_owner, :foreign_key => 'current_owner_id'

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
  end

  api_accessible :player_private_with_megatiles, :extend => :player_private do |template|
    template.add :megatiles, :template => :id_and_name
  end

  api_accessible :player_public_with_megatiles, :extend => :player_public do |template|
    template.add :megatiles, :template => :id_and_name
  end

end
