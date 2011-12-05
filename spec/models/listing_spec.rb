require 'spec_helper'

describe Listing do
  it { should belong_to :owner }
  it { should belong_to :megatile_grouping }
  it { should have_one :world }
  it { should have_many :bids }
  it { should have_one :accepted_bid }

  it { should validate_numericality_of :price }

  describe 'validation' do
    describe '#price' do
      it 'disallows negative amounts' do
        build(:listing, price: -0.01).should_not be_valid
      end
    end

    context 'with multiple megatile owners' do
      subject { build(:listing_with_multiple_megatile_owners) }
      it 'is not valid' do
        it { should not be_valid }
      end
    end
  end

  # validate :at_least_one_megatile_must_be_present
end
