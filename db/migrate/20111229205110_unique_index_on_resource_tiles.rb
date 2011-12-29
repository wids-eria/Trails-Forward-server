class UniqueIndexOnResourceTiles < ActiveRecord::Migration
  def up
    remove_index :resource_tiles, [:x, :y, :world_id]
    add_index :resource_tiles, [:x, :y, :world_id], unique: true
  end

  def down
    remove_index :resource_tiles, :column => [:x, :y, :world_id]
    add_index :resource_tiles, [:x, :y, :world_id]
  end
end
