require 'set'

class Bid < ActiveRecord::Base
  versioned
  acts_as_api

  Verbiage = {:active => "Offered",
              :offered => "Offered",
              :accepted => "Accepted",
              :rejected => "Rejected",
              :cancelled => "Cancelled"
  }

  belongs_to :bidder, :class_name => 'Player', :foreign_key => 'bidder_id'
  belongs_to :current_owner, :class_name => 'Player'
  belongs_to :listing

  belongs_to :counter_to, :class_name => 'Bid'
  has_many :counter_bids, :class_name => 'Bid', :foreign_key => 'counter_to_id'

  # land offered as PAYMENT on a listing
  belongs_to :offered_land, :class_name => "MegatileGrouping"

  #land that is being PURCHASED by the bidder. In the case of a fully solicited buy, this == listing.megatile_grouping.meagtiles
  belongs_to :requested_land, :class_name => "MegatileGrouping"

  validates_presence_of :money
  validates_numericality_of :money
  validates :money, :numericality => {:greater_than_or_equal_to => 0}
  validate :requested_land_must_all_have_same_owner

  scope :active, lambda { where(:status => Verbiage[:active]) }



  def requested_land_must_all_have_same_owner
    owners = Set.new

    requested_land.megatiles.each do |mt|
      owners << mt.owner
    end

    if owners.count > 1
      errors.add(:requested_land, "must all have the same current owner")
    end
  end

  def is_active?
    self.status == Verbiage[:active]
  end

  def is_counter_bid?
    counter_to != nil
  end

  def money_must_be_nonnegative
    errors.add(:money, "must be >= 0") unless (money >= 0)
  end

  def sale_pending
    self.status == Verbiage[:accepted] and not self.execution_complete
  end

  api_accessible :bid_public do |template|
    template.add :id
    template.add :bidder, :template => :player_public
    template.add :updated_at
    template.add :status
    template.add :sale_pending, :as => :pending, :if => lambda{|b| b.sale_pending}
  end

  api_accessible :bid_private, :extend => :bid_public do |template|
    template.add :money
    template.add :counter_to, :template => :bid_public, :if => :is_counter_bid?
    template.add 'offered_land.megatiles', :as => :offered_land, :template => :id_and_name, :if => lambda{|b| b.offered_land != nil}
    template.add 'requested_land.megatiles', :as => :requested_land, :template => :id_and_name, :if => lambda{|b| b.requested_land != nil}
  end


end
