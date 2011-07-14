class AddDefaultExecutionCompleteToBid < ActiveRecord::Migration
  def self.up
    change_column :bids, :execution_complete, :boolean, :default => false
  end

  def self.down
    change_column :bids, :execution_complete, :boolean
  end
end
