require 'chunky_png'

class WorldPresenter
  def initialize(world)
    @world = world
  end

  # create the immutable properties for the world into an image
  def to_png

    # create the image
    # land tile = black, water tile = white
    canvas = ChunkyPNG::Image.new @world.width, @world.height, ChunkyPNG::Color::BLACK
    ResourceTile.where(:world_id => @world.id).find_in_batches do |group|
      group.each do |rt|
        x = rt.x
        y = rt.y
        case rt.type
        when WaterTile.to_s
          canvas[x,y] = ChunkyPNG::Color::WHITE
        end
      end
    end

    return canvas

  end

  # save the immutable properties for the world into an image to
  # the appropriate path
  def save_png

    # create the image
    canvas = to_png

    # create the path
    path = "public/worlds/#{@world.id}/images"
    FileUtils.mkdir_p path

    # save the image
    filename = "#{path}/world.png"
    canvas.save filename, :best_compression

  end


end
