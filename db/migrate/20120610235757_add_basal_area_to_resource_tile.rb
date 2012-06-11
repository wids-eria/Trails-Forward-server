class AddBasalAreaToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :small_tree_basal_area, :float
    add_column :resource_tiles, :large_tree_basal_area, :float
  end
end
