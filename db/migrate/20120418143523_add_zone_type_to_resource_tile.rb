class AddZoneTypeToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :zone_type, :string
  end
end
