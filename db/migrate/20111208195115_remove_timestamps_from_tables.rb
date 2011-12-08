TABLES_TO_UPDATE = %w(megatile_groupings megatiles players resource_tiles)

class RemoveTimestampsFromTables < ActiveRecord::Migration
  def up
    TABLES_TO_UPDATE.each do |table|
      remove_column table, :created_at
      remove_column table, :updated_at
    end
  end

  def down
    TABLES_TO_UPDATE.each do |table|
      add_column table, :updated_at, :datetime
      add_column table, :created_at, :datetime
    end
  end
end
