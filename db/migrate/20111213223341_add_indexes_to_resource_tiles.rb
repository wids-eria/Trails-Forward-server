class AddIndexesToResourceTiles < ActiveRecord::Migration
  def change
    add_index :resource_tiles, [:x, :y, :world_id]
  end
end
