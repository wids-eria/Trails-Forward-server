class AddLakesizeToResourceTiles < ActiveRecord::Migration
  def self.up
    add_column :resource_tiles, :lakesize, :float
  end

  def self.down
    remove_column :resource_tiles, :lakesize
  end
end
