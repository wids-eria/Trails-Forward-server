require File.expand_path("../../../config/environment", __FILE__)
require 'beanstalk-client'
require 'stalker'
include Stalker

tick_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], 'agent.tick.complete')

job 'agent.tick' do |args|
  agent = Agent.find args["agent_id"]
  agent.tick!
  tick_complete_stalk.put(agent.id)
end
