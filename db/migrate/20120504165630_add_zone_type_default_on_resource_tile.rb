class AddZoneTypeDefaultOnResourceTile < ActiveRecord::Migration
  def up
    change_column :resource_tiles, :zone_type, :string, :default => 'none'
  end

  def down
    change_column :resource_tiles, :zone_type, :string
  end
end
