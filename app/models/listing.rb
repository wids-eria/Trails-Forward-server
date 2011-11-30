require 'set'

class Listing < ActiveRecord::Base
  acts_as_api

  belongs_to :owner, :class_name => 'Player'
  belongs_to :megatile_grouping

  has_one :world, :through => :owner

  has_many :bids
  has_one :accepted_bid, :class_name => "Bid"

  Verbiage = {:active => "Active",
              :cancelled => "Cancelled",
              :sold => "Sold"
  }

  validates :price, :numericality => {:greater_than_or_equal_to => 0}
  validate :all_megatiles_are_owned_by_owner
  validate :at_least_one_megatile_must_be_present

  def megatiles
    megatile_grouping.megatiles
  end

  def is_active?
    self.status == Verbiage[:active]
  end

  def at_least_one_megatile_must_be_present
    errors.add(:megatiles, "must contain at least one megatile") unless megatiles.count > 0
  end

  def all_megatiles_are_owned_by_owner
    if megatile_grouping
      owners = Set.new

      megatile_grouping.megatiles.each do |megatile|
        owners << megatile.owner
      end

      if owners.count != 1
        errors.add(:megatiles, "must all have the same owner")
      elsif owners.first != owner
        errors.add(:megatiles, "must all be owned by the lister")
      end
    end
  end

  api_accessible :listing do |template|
    template.add :id
    template.add :owner, :template => :player_public
    template.add :status
    template.add :price
    template.add 'bids.count', :as => :bid_count
    template.add :megatiles, :template => :id_and_name
  end

end
