class SetMartenDefaultsToZero < ActiveRecord::Migration
  def up
    change_column :resource_tiles, :marten_suitability, :integer, :default => 0
    change_column :worlds, :marten_suitable_tile_count, :integer, :default => 0
  end

  def down
    change_column :resource_tiles, :marten_suitability, :integer
    change_column :worlds, :marten_suitable_tile_count, :integer
  end
end
