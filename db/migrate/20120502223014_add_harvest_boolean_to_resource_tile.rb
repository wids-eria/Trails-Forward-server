class AddHarvestBooleanToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :harvest_area, :boolean, :default => false
  end
end
