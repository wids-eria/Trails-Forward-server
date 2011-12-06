require 'spec_helper'

describe Bid do
  it { should belong_to :bidder }
  it { should belong_to :current_owner }
  it { should belong_to :listing }

  it { should belong_to :counter_to }
  it { should have_many :counter_bids }

  it { should belong_to :offered_land }
  it { should belong_to :requested_land } 

  it { should validate_presence_of :money }
  it { should validate_presence_of :requested_land }
  it { should validate_numericality_of :money }

  describe 'factory' do
    it 'should produce multiple valid bids' do
      create(:bid).should be_valid
      build(:bid).should be_valid
    end
  end

  describe 'validation' do
    describe 'money' do
      it 'disallows negative amounts' do
        build(:bid, money: -1.50).should_not be_valid
      end
    end
    describe 'requested_land' do
      context 'with multiple owners' do
        before :all do
          Player.count.should == 0
        end

        let(:ben) { create :player }
        let(:world) { ben.world }
        let(:kevin) { create :player, world: world }
        let(:bens_tile) { world.megatiles.first }
        let(:kevins_tile) { world.megatiles.last }
        let(:requested_land) { create :megatile_grouping, megatiles: [kevins_tile, bens_tile] }

        before do
          bens_tile.update_attributes(owner: ben)
          kevins_tile.update_attributes(owner: kevin)
        end

        it 'is not valid' do
          build(:bid, requested_land: requested_land).should_not be_valid
        end
      end
    end
  end
end
