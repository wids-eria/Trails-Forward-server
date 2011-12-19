require 'spec_helper'

describe Flycatcher do
  describe 'factory' do
    it 'should produce multiple valid flycatchers' do
      create(:flycatcher).should be_valid
      build(:flycatcher).should be_valid
    end
  end
end
