namespace :trails_forward do
  namespace :init do
    desc "Initialize a sample world with random data"
    task :create_random_world, [:width, :height] => [:environment] do |t, args|
      args[:width] ||= 6
      args[:height] ||= 6
      create :world_with_properties, args
    end
  end
end
