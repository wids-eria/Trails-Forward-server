class CreateChangeRequests < ActiveRecord::Migration
  def self.up
    create_table :change_requests do |t|
      t.string :type
      t.integer :target_id
      t.string :target_type

      #for development requests
      t.string :development_type
      t.string :development_quality

      t.timestamps
    end
  end

  def self.down
    drop_table :change_requests
  end
end
