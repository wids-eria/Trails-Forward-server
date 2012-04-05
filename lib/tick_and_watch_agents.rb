require 'beanstalk-client'
require 'stalker'

Split_Size = 10.0

tick_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], 'turtle.tick.complete')

w = World.last

ProgressBar.color_status
ProgressBar.iter_rate_mode

def split_agents_for_world(world)
  x_min = 0
  x_max = world.width
  x_split_size = (x_max - x_min) / Split_Size
  y_min = 0
  y_max = world.height
  y_split_size = (y_max - y_min) / Split_Size
  
  ret = []
  
  Split_Size.to_i.times do |x_iter|
    x_left = x_min + x_iter * x_split_size
    x_right = x_left + x_split_size
    Split_Size.to_i.times do |y_iter|
      y_bottom = y_min + y_iter * y_split_size
      y_top = y_bottom + y_split_size
      
      #agents = Agent.where(:world_id=>world.id,  :_x.gte => x_left, :_x.lt => x_right, :_y.gte => y_bottom, :_y.lt => y_top)
      agents = Agent.where( "world_id = ? AND x >= ? AND x < ? AND y >=? AND y < ?",  world.id, x_left, x_right, y_bottom, y_top)
      ret << agents.map { |t| t.id }
    end
  end
  ret
end

def enqueue(agent_lists)
  agent_lists.each do |tl|
    #puts "Would have enqueued: #{tl}"  
    #Stalker.enqueue('batch.tick', :agent_ids => tl)
    tl.each do |agent_id|
      Stalker.enqueue('agent.tick', :agent_id => agent_id)
    end
  end
end

10.times do |clock|
  agent_count = w.agents.count
  pb = ProgressBar.new("Tick #{clock}", agent_count)
  #Stalker.enqueue('world.tick', :world_id => w.id)
  enqueue split_agents_for_world w
  agent_count.times do
    job = tick_complete_stalk.reserve
    job.delete
    pb.inc
  end
  pb.finish
end
