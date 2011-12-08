require 'set'

class Bid < ActiveRecord::Base
  acts_as_api

  def self.verbiage
    { active: "Offered",
      offered: "Offered",
      accepted: "Accepted",
      rejected: "Rejected",
      cancelled: "Cancelled" }
  end

  belongs_to :bidder, class_name: 'Player', foreign_key: 'bidder_id'
  belongs_to :current_owner, class_name: 'Player'
  belongs_to :listing

  belongs_to :counter_to, class_name: 'Bid'
  has_many :counter_bids, class_name: 'Bid', foreign_key: 'counter_to_id'

  belongs_to :requested_land, class_name: "MegatileGrouping" # Listing Purchase (tiles being sold)
  belongs_to :offered_land, class_name: "MegatileGrouping" # Listing Payment

  has_many :requested_megatiles, through: :requested_land, source: :megatiles
  has_many :offered_megatiles, through: :offered_land, source: :megatiles

  validates :money,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :requested_land,
    presence: true

  validate :requested_land_must_all_have_same_owner

  scope :active, conditions: { status: Bid.verbiage[:active] }


  def is_active?
    self.status == Bid.verbiage[:active]
  end

  def is_counter_bid?
    counter_to != nil
  end

  def money_must_be_nonnegative
    errors.add(:money, "must be >= 0") unless (money >= 0)
  end

  def sale_pending
    self.status == Bid.verbiage[:accepted] and not self.execution_complete
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

private

  def requested_land_must_all_have_same_owner
    if requested_land.present?
      owners = requested_megatiles.collect(&:owner).uniq

      if owners.count > 1
        errors.add(:requested_land, "must all have the same current owner")
      end
    end
  end

end
