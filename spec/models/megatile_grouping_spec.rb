require 'spec_helper'

describe MegatileGrouping do
  describe 'factory' do
    it 'should produce multiple valid megatile_grouping' do
      create(:megatile_grouping).should be_valid
      build(:megatile_grouping).should be_valid
    end
  end

end
