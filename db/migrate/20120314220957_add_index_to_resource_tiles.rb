class AddIndexToResourceTiles < ActiveRecord::Migration
  def change
    add_index :resource_tiles, :megatile_id
  end
end
