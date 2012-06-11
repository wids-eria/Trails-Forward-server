class RemoveMartenSuitableTileCountFromWorld < ActiveRecord::Migration
  def up
    remove_column :worlds, :marten_suitable_tile_count
  end

  def down
    add_column :worlds, :marten_suitable_tile_count, :integer
  end
end
