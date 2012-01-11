### SETUP ################################

world_id = ARGV[0]

tick_count = 1000

ProgressBar.color_status
ProgressBar.iter_rate_mode


### TICK #################################

world = MongoWorld.find(world_id)
agent_count = world.mongo_agents.count

tick_count.times.each do |n|
  $bar = ProgressBar.new("Ticks #{n}", agent_count)
  world.reload
  world.tick
  $bar.finish
end

