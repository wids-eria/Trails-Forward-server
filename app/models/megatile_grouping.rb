class MegatileGrouping < ActiveRecord::Base
  has_and_belongs_to_many :megatiles

  has_many :listings

  has_many :bids_on, :class_name => 'Bid', :foreign_key => 'requested_land_id'
  has_many :bids_offering, :class_name => 'Bid', :foreign_key => 'offered_land_id'
end
