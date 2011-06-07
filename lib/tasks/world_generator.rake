require Rails.root.join("lib/example_world_builder")

namespace :trails_forward do
  namespace :init do
    desc "Initialize a sample world with random data"
    task :create_random_world, :width, :height, :needs => [:environment] do |t, args|
      ExampleWorldBuilder.build_example_world args[:width], args[:height], true
    end
  end #namespace :init
end #namespace :trails_forward