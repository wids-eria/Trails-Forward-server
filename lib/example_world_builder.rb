class ExampleWorldBuilder
  def self.build_example_world(args = {})
    world = Factory :world_with_properties, args
  end
end
