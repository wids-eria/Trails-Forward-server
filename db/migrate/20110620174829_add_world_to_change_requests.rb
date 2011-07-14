class AddWorldToChangeRequests < ActiveRecord::Migration
  def self.up
    add_column :change_requests, :world_id, :integer
    add_index :change_requests, :world_id
  end

  def self.down
    remove_column :change_requests, :world_id
  end
end
