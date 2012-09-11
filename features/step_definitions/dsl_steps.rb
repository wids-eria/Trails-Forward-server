$seq ||= 0

Given /^agent class:$/ do |class_code|
  class_name = "TestAgent#{$seq += 1}"

  eval <<EOS
    class #{class_name} < Agent
      #{class_code}
    end
EOS

  @agent_class = class_name.constantize
end

When /^(\d+) of those agents are ticked (\d+) times$/ do |num_agents, num_ticks|
  @world = Factory :world_with_tiles
  num_agents.to_i.times do
    @agent_class.create! world: @world, x: 0, y: 0, heading: 0
  end

  $rand = Random.new(0)

  @agent_class.class_eval do
    define_method :rand do |*val|
      $rand.rand *val
    end
  end

  num_ticks.to_i.times do
    @world.agents.each(&:tick)
  end
end

Then /the population of those agents should be (\d+) with a tolerance of (\d+)$/ do |target_population, tolerance|
  population = @world.agents.count
  if (population - target_population.to_i).abs > tolerance.to_i
    population.should == target_population.to_i
  end
end
