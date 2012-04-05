require 'chunky_png'

class WorldPresenter
  attr_accessor :world

  def initialize(world)
    self.world = world
  end

  # create the immutable properties for the world into an image
  def to_png
    world.to_png
  end

  # save the immutable properties for the world into an image to
  # the appropriate path
  def save_png
    # create the path
    FileUtils.mkdir_p path_to

    # save the image
    world.generate_png full_path(:large)

    image = MiniMagick::Image.open(full_path(:large))
    image.resize "150x80"
    image.write full_path
  end

  def path_to
    "public/worlds/#{world.id}/images"
  end

  def filename(postfix = '')
    postfix = "_#{postfix}" unless postfix.blank?
    "world#{postfix}.png"
  end

  def full_path(postfix = '')
    File.join(path_to, filename(postfix))
  end
end
