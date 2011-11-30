require 'spec_helper'

describe Bid do
  it { should belong_to :bidder } #, :class_name => 'Player', :foreign_key => 'bidder_id' }
  it { should belong_to :current_owner } #, :class_name => 'Player' }
  it { should belong_to :listing }

  # belongs_to :counter_to, :class_name => 'Bid'
  # has_many :counter_bids, :class_name => 'Bid', :foreign_key => 'counter_to_id'

  # # land offered as PAYMENT on a listing
  # belongs_to :offered_land, :class_name => "MegatileGrouping"

  # #land that is being PURCHASED by the bidder. In the case of a fully solicited buy, this == listing.megatile_grouping.meagtiles
  # belongs_to :requested_land, :class_name => "MegatileGrouping"

  # validates_presence_of :money
  # validates_numericality_of :money
  # validates :money, :numericality => {:greater_than_or_equal_to => 0}
  # validate :requested_land_must_all_have_same_owner
end
