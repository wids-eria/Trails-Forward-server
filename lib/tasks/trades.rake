namespace :trails_forward do
  namespace :trades do  
    
    desc "Execute all pending trades in the world"
    task :execute_pending, :world_id, :needs => [:environment] do |t, args|
      world = World.find args[:world_id]
      broker = world.manager.broker
      world.lock!
      trade_requests = world.pending_change_requests.where(:type => TransferChangeRequest.to_s)
      ActiveRecord::Base.transaction do
        trade_requests.each do |tr|
          if not tr.complete
            bid = tr.target
            broker.transfer_assets bid
            bid.execution_complete = true
            bid.save!
            tr.complete = true
            tr.save!
          end
        end #tr.each
      end   #transaction
    end     #task
    
  end   
end