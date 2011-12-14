class AddClassCodeToResourceTiles < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :landcover_class_code, :integer
  end
end
