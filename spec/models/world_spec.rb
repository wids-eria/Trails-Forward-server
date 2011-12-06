require 'spec_helper'

describe World do
  describe 'factory' do
    it 'should produce multiple valid worlds' do
      create(:world).should be_valid
      build(:world).should be_valid
    end
  end

  context "when first created" do
    let(:world) { create :world }
    subject { world }
    its(:resource_tiles) { should be_empty }
    its(:megatiles) { should be_empty }
    its(:players) { should be_empty }
  end

  context "when initialized with dummy data" do
    let(:world) { create :world_with_properties }
    subject { world }
    its(:resource_tiles) { should_not be_empty }
    its(:megatiles) { should_not be_empty }
    its(:players) { should_not be_empty }
  end
end
