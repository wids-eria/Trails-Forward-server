require 'world_to_img'

namespace :trails_forward do
  namespace :init do
    
    desc "Save the immutable properties for the world into an image"
    task :create_world_img, :world_id, :needs => [:environment] do |t, args|
      create_world_img args[:world_id]
    end #task

  end
end
