require Rails.root.join("lib/example_world_builder")

namespace :trails_forward do
  namespace :init do
    desc "Initialize a sample world with random data"
    task :create_random_world, [:width, :height] => [:environment] do |t, args|
      ExampleWorldBuilder.build_example_world args
    end
  end
end
