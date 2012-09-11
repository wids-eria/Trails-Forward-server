class AddIndexToTypeOnResourceTile < ActiveRecord::Migration
  def change
    add_index :resource_tiles, [:world_id, :type]
  end
end
