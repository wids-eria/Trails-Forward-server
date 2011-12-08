class RemoveVersions < ActiveRecord::Migration
  def up
    drop_table :versions

    %w(bids listings megatiles players resource_tiles).each do |table|
      remove_column table, :lock_version
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
