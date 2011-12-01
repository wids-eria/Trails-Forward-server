namespace :trails_forward do
  namespace :init do

    desc "Save the immutable properties for the world into an image"
    task :create_world_img, [:world_id] => [:environment] do |t, args|
      world = World.find args[:world_id]
      WorldPresenter.new(world).save_png
    end

  end
end
