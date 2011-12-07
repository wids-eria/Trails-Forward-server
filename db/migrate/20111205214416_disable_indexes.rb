class DisableIndexes < ActiveRecord::Migration
  def up
    remove_index :megatiles, :world_id
    remove_index :megatiles, :x
    remove_index :megatiles, :y
    remove_index :megatiles, :owner_id

    remove_index :resource_tiles, :megatile_id
    remove_index :resource_tiles, :x
    remove_index :resource_tiles, :y
    remove_index :resource_tiles, :world_id
  end

  def down
    add_index :resource_tiles, :world_id
    add_index :resource_tiles, :y
    add_index :resource_tiles, :x
    add_index :resource_tiles, :megatile_id

    add_index :megatiles, :owner_id
    add_index :megatiles, :y
    add_index :megatiles, :x
    add_index :megatiles, :world_id
  end
end
