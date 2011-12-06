require 'spec_helper'

describe Listing do
  it { should belong_to :owner }
  it { should belong_to :megatile_grouping }
  it { should have_one :world }
  it { should have_many :bids }
  it { should have_one :accepted_bid }

  it { should validate_numericality_of :price }

  describe 'factory' do
    it 'should produce multiple valid listings' do
      create(:listing).should be_valid
      build(:listing).should be_valid
    end
  end

  describe 'validation' do
    describe '#price' do
      it 'disallows negative amounts' do
        build(:listing, price: -0.01).should_not be_valid
      end
    end

    context 'with no megatiles' do
      let(:listing) { build :listing, megatile_grouping: create(:megatile_grouping) }
      subject { listing }

      its(:megatiles) { should be_empty }
      it { should_not be_valid }
    end

    context 'with multiple megatile owners' do
      let(:listing) { create :listing }
      subject { listing }
      before { listing.megatiles.last.update_attributes owner: create(:player) }

      it { should_not be_valid }
    end
  end

end
