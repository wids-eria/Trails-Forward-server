require 'spec_helper'

describe Flycatcher do
  describe 'factory' do
    it 'should produce multiple valid flycatchers' do
      create(:flycatcher).should be_valid
      build(:flycatcher).should be_valid
    end
  end

  describe '#state' do
    let(:flycatcher) { build :flycatcher }
    subject { flycatcher }
    context 'initial' do
      it { should be_migrated }
    end

    describe '#seek_nest' do
      it 'allows transition to from migrated' do
        flycatcher.seek_nest!
        flycatcher.should be_seeking_nest
      end

      it 'does not allow transition from nested' do
        flycatcher.update_attributes state: 'nested'
        lambda do
          flycatcher.seek_nest!
        end.should raise_error
      end
    end

  end
end
