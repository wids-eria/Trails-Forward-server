require 'spec_helper'

require Rails.root.join("lib/example_world_builder")

describe WorldPresenter do
  let(:world) { ExampleWorldBuilder.build_example_world }

  describe "#to_png" do
    let(:canvas) { WorldPresenter.new(world) }
    subject { canvas.to_png }

    it 'colors water and land correctly' do
      world.each_resource_tile do |tile|
        subject[tile.x, tile.y].should == case tile.type
                                          when WaterTile.to_s then ChunkyPNG::Color::WHITE
                                          when LandTile.to_s  then ChunkyPNG::Color::BLACK
                                          end
      end
    end

  end


  describe "#save_png" do
    let(:filename) { "public/worlds/#{world.id}/images/world.png" }
    before { WorldPresenter.new(world).save_png }
    it 'saves the map to disk' do
      File.exists?(filename).should == true
    end
  end

end
