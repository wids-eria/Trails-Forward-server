require 'stalker'
include Stalker

job 'agent_tick' do |args|
  progeny = Agent.find(args[:agent_id]).tick! || []
  Stalker.enqueue('agent_tick_complete', progeny: progeny)
end

