class AddIndexOnCompleteToChangeRequest < ActiveRecord::Migration
  def self.up
    add_index :change_requests, :complete
  end

  def self.down
    remove_index :change_requests, :complete
  end
end
