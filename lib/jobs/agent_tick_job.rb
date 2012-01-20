APP_PATH = File.expand_path('../../../config/application',  __FILE__)
require File.expand_path('../../../config/boot',  __FILE__)
require 'stalker'
include Stalker

job 'agent_tick' do |args|
  progeny = Agent.find(args[:agent_id]).tick! || []
  Stalker.enqueue('agent_tick_complete', progeny: progeny)
end

