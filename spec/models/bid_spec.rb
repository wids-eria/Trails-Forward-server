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
  it { should validate_numericality_of :money }
  # it { should validate_numericality_of :money, :greater_than_or_equal_to => 0 }

  describe 'validation' do
    describe 'money' do
      it 'disallows negative amounts' do
        Bid.new(money: -1.50).should_not be_valid
      end
    end
    describe 'requested_land' do
      context 'with multiple owners' do
        let(:ben_user) { create :user, name: 'Ben' }
        let(:kevin_user) { create :user, name: 'Kevin' }
        let(:ben) { Player.create user: ben_user }
        let(:kevin) { Player.create user: kevin_user }
        let(:bens_tile) { Megatile.create owner: ben }
        let(:kevins_tile) { Megatile.create owner: kevin }
        let(:requested_land) { MegatileGrouping.create(megatiles: [kevins_tile, bens_tile]) }

        it 'is not valid' do
          Bid.new(requested_land: requested_land).should_not be_valid
        end
      end
    end
  end
end
