class AddSoilToResourceTiles < ActiveRecord::Migration
  def self.up
    add_column :resource_tiles, :soil, :integer
  end

  def self.down
    remove_column :resource_tiles, :soil
  end
end
