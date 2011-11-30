require 'spec_helper'

describe Bid do
  it { should belong_to :bidder } #, :class_name => 'Player', :foreign_key => 'bidder_id' }
  it { should belong_to :current_owner } #, :class_name => 'Player' }
  it { should belong_to :listing }

  it { should belong_to :counter_to }
  it { should have_many :counter_bids }

  it { should belong_to :offered_land }
  it { should belong_to :requested_land } 

  it { should validate_presence_of :money }
  it { should validate_presence_of :requested_land }
  # validates_presence_of :money
  # validates_numericality_of :money
  # validates :money, :numericality => {:greater_than_or_equal_to => 0}
  # validate :requested_land_must_all_have_same_owner
end
