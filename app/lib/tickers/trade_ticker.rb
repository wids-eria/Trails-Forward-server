class TradeTicker
  def self.tick(world)
    broker = world.manager.broker
    trade_requests = world.pending_change_requests.where(:type => TransferChangeRequest.to_s)
    ActiveRecord::Base.transaction do
      world.lock!
      trade_requests.each do |tr|
        if not tr.complete
          bid = tr.target
          broker.transfer_assets bid
          bid.execution_complete = true
          bid.save!
          tr.complete = true
          tr.save!
        end
      end
    end
  end
end
