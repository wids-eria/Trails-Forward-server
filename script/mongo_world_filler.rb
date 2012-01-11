### SETUP ################################

world_id = ARGV[0]

population_size = 10000
ProgressBar.color_status
ProgressBar.iter_rate_mode

### SPAWN #################################

def randomized_coordinate(value)
  rand(value) + rand
end

world = MongoWorld.find(world_id)

bar = ProgressBar.new("Spawn Agents", population_size)
population_size.times.each do 
  agent = MongoAgent.new mongo_world_id: world.id, x:randomized_coordinate(world.width) , y:randomized_coordinate(world.height)
  agent.save
  bar.inc
end
bar.finish
