require 'spec_helper'

require Rails.root.join("lib/example_world_builder")

describe do
  it "test WorldPresenter to_png" do

    # create a world
    world = ExampleWorldBuilder.build_example_world 6, 6

    # convert the world to png
    canvas = WorldPresenter.new(world).to_png;

    # make sure the pixel value match the resource type
    Range.new(0,world.width-1).each do |x|
      Range.new(0,world.height-1).each do |y|
        rt =  world.resource_tile_at x,y
        case rt.type
        when WaterTile.to_s
          canvas[x,y].should == ChunkyPNG::Color::WHITE
        when LandTile.to_s
          canvas[x,y].should == ChunkyPNG::Color::BLACK
        end
      end
    end

  end

  it "test WorldPresenter save_png" do

    # create a world
    world = ExampleWorldBuilder.build_example_world 6, 6

    # save the world as an image
    WorldPresenter.new(world).save_png;

    # check if the image was saved
    filename = "public/worlds/#{world.id}/images/world.png"
    File.exists?(filename).should == true

  end

end
