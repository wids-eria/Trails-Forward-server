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

  # land offered as PAYMENT on a listing
  belongs_to :offered_land, class_name: "MegatileGrouping"

  # land that is being PURCHASED by the bidder. In the case of a fully solicited buy, this == listing.megatile_grouping.meagtiles
  belongs_to :requested_land, class_name: "MegatileGrouping"

  validates :money, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :requested_land, presence: true
  validate :requested_land_must_all_have_same_owner

  scope :active, conditions: { status: Bid.verbiage[:active] }

  Bid.verbiage.keys.each do |key|
    define_method "is_#{key}?" do
      self.status == Bid.verbiage[key]
    end
  end

  def is_counter_bid?
    counter_to != nil
  end

  def complete_execution!
    self.execution_complete = true
    save!
  end

  def accepted?
    self.status == Bid.verbiage[:accepted]
  end

  def accept
    self.status = Bid.verbiage[:accepted]
  end

  def accept!
    accept
    save!
  end

  def sale_pending
    self.accepted? and not self.execution_complete?
  end

  api_accessible :bid_public do |template|
    template.add :id
    template.add :bidder, template: :player_public
    template.add :updated_at
    template.add :status
    template.add :sale_pending, as: :pending, if: lambda{|b| b.sale_pending}
  end

  api_accessible :bid_private, extend: :bid_public do |template|
    template.add :money
    template.add :counter_to, template: :bid_public, if: :is_counter_bid?
    template.add 'offered_land.megatiles', as: :offered_land, template: :id_and_name, if: lambda{|b| b.offered_land != nil}
    template.add 'requested_land.megatiles', as: :requested_land, template: :id_and_name, if: lambda{|b| b.requested_land != nil}
  end

private

  def requested_land_must_all_have_same_owner
    if requested_land.present?
      owners = Set.new

      requested_land.megatiles.each do |mt|
        owners << mt.owner
      end

      if owners.count > 1
        errors.add(:requested_land, "must all have the same current owner")
      end
    end
  end

end
