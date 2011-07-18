class AddFrontageToResourceTiles < ActiveRecord::Migration
  def self.up
    add_column :resource_tiles, :frontage, :float
  end

  def self.down
    remove_column :resource_tiles, :frontage
  end
end
