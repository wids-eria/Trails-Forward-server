class AddCompleteToChangeRequest < ActiveRecord::Migration
  def self.up
    add_column :change_requests, :complete, :boolean, :default => false
  end

  def self.down
    remove_column :change_requests, :complete
  end
end
