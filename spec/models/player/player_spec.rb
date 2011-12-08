require 'spec_helper'

describe Player do
  it { should belong_to :user }
  it { should belong_to :world }

  it { should have_many :megatiles }
  it { should have_many :resource_tiles }

  describe 'factory' do
    it 'should produce multiple valid players' do
      create(:player).should be_valid
      build(:player).should be_valid
    end
  end

  describe '.default_balance' do
    example 'should be 1000' do
      Player.default_balance.should == 1000
    end
  end

  describe 'validation' do
    let!(:player1) { create :player }
    example 'user_id should be valid per world' do
      player2 = build :player, user_id: player1.user_id, world: player1.world
      player2.valid?
      player2.errors.messages[:user_id].should include('has already been taken')
    end
  end

  it { should validate_presence_of :user }
  it { should validate_presence_of :world }
  it { should validate_numericality_of :balance }
  it { should validate_presence_of :balance }

  it { should have_many :bids_placed }
  it { should have_many :bids_received }
end
