class SwapResourceTileXYWorldIndexOrder < ActiveRecord::Migration
  def up
    remove_index :resource_tiles, :column => [:x, :y, :world_id]
    add_index :resource_tiles, [:world_id, :x, :y], unique: true
  end

  def down
    remove_index :resource_tiles, :column => [:world_id, :x, :y]
    add_index :resource_tiles, [:x, :y, :world_id], unique: true
  end
end
