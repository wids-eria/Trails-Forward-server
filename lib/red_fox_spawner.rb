world = World.last


num_red_foxes = 100000

red_fox_pb = ProgressBar.new('Red foxes', num_red_foxes)

num_red_foxes.times do
  location = []
  resource_tile = ''
  begin
    location = [rand * world.width, rand * world.height]
    resource_tile = world.resource_tile_at(*location.map(&:floor))
  end until resource_tile.type == 'LandTile' && resource_tile.tree_density > 0.4
  red_fox = Factory.create :red_fox,
                            world: world,
                            location: location,
                            heading: rand(360).round,
                            age: [Agent.normal_dist(2,5), 0].max.floor
  red_fox_pb.inc
end
red_fox_pb.finish