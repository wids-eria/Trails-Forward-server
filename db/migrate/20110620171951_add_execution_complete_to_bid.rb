class AddExecutionCompleteToBid < ActiveRecord::Migration
  def self.up
    add_column :bids, :execution_complete, :boolean
  end

  def self.down
    remove_column :bids, :execution_complete
  end
end
