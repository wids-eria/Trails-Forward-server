require File.expand_path("../../../config/environment", __FILE__)
require 'beanstalk-client'
require 'stalker'
include Stalker

tick_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], 'turtle.tick.complete')


job 'world.tick' do |args|
  world = World.find args["world_id"]
  world.turtles.each do |turtle|
    enqueue('agent.tick', :turtle_id => turtle.id)
  end
end

job 'agent.tick' do |args|
  agent = Agent.find args["agent_id"]
  agent.tick!
  tick_complete_stalk.put(agent.id)
end

job 'batch.tick' do |args|
  agents = Agent.find args["agent_ids"]
  agents.each do |agent|
    Rails.logger.info "*"*69
    agent.tick!
    tick_complete_stalk.put(agent.id)
  end
end
