require 'spec_helper'

require Rails.root.join("lib/example_world_builder")

describe World do
  context "when first created" do
    let(:world) { create :world }
    subject { world }
    its(:resource_tiles) { should be_empty }
    its(:megatiles) { should be_empty }
    its(:players) { should be_empty }
  end

  context "when initialized with dummy data" do
    let(:world) { ExampleWorldBuilder.build_example_world }
    subject { world }
    its(:resource_tiles) { should_not be_empty }
    its(:megatiles) { should_not be_empty }
    its(:players) { should_not be_empty }
  end
end
