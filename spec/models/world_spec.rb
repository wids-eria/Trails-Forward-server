require 'spec_helper'

require Rails.root.join("lib/example_world_builder")

describe World do
  context "when first created" do
    it "is empty" do
      world = World.new do |w|
        w.name = "Example World #{rand(100000)}"
        w.year_start = 1880
        w.year_current = 1880
        w.width = 6
        w.height = 6
        w.megatile_width = 3
        w.megatile_height = 3
      end
      world.resource_tiles.should be_empty
      world.megatiles.should be_empty
      world.players.should be_empty
    end
  end

  context "when initialized with dummy data" do
    let(:world) { ExampleWorldBuilder.build_example_world 6, 6 }
    subject { world }
    its(:resource_tiles) { should_not be_empty }
    its(:megatiles) { should_not be_empty }
    its(:players) { should_not be_empty }
  end
end
