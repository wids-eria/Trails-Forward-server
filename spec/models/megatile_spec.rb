require 'spec_helper'

describe Megatile do
  it { should validate_presence_of(:world) }

  describe 'factory' do
    it 'should produce multiple valid megatiles' do
      create(:megatile).should be_valid
      build(:megatile).should be_valid
    end
  end

end
