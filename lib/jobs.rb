file = File.expand_path(File.join("..", "..", "config", "environment"), __FILE__)
puts file
require file

job 'mongo_agent.tick' do |args|
  puts args.inspect
  agent = MongoAgent.find args["agent_id"]
  agent.tick
  agent.save
end
