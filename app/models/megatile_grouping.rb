class MegatileGrouping < ActiveRecord::Base
  has_many :megatile_grouping_megatiles
  has_many :megatiles, :through => :megatile_grouping_megatiles #, :class_name => "MegatileGroupingMegatile"
  has_many :listings

  #bids offering to buy this grouping
  has_many :bids_on, :class_name => 'Bid', :foreign_key => 'requested_land_id'

  #bids offering to include this grouping as payment
  has_many :bids_offering, :class_name => 'Bid', :foreign_key => 'offered_land_id'
end
