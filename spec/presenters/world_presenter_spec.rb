require 'spec_helper'

require Rails.root.join("lib/example_world_builder")

describe WorldPresenter do
  let(:world) { ExampleWorldBuilder.build_example_world 6, 6 }

  describe "#to_png" do
    let(:canvas) { WorldPresenter.new(world) }
    subject { canvas.to_png }

    it 'colors water and land correctly' do
      (0...world.width).each do |x|
        (0...world.height).each do |y|
          subject[x,y].should == case world.resource_tile_at(x,y).type
                                 when WaterTile.to_s then ChunkyPNG::Color::WHITE
                                 when LandTile.to_s  then ChunkyPNG::Color::BLACK
                                 end
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
