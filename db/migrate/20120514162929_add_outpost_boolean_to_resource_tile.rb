class AddOutpostBooleanToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :outpost, :boolean, :default => false
  end
end
