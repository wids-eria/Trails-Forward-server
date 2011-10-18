require 'chunky_png'

# save the immutable properties for the world into an image
def create_world_img(world_id)
    
  world = World.find world_id
  canvas = ChunkyPNG::Image.new world.width, world.height, ChunkyPNG::Color::BLACK

  ResourceTile.where(:world_id => world.id).find_in_batches do |group|
    group.each do |rt|
      x = rt.x
      y = rt.y
      case rt.type
        when WaterTile.to_s
          canvas[x,y] = ChunkyPNG::Color::WHITE
      end
    end
  end

  # create the path
  path = "public/worlds/#{world_id}/images"
  FileUtils.mkdir_p path

  # save the image
  filename = "#{path}/world.png"
  canvas.save filename, :best_compression

end
