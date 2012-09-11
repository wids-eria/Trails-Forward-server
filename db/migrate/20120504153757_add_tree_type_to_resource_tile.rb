class AddTreeTypeToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :tree_type, :string, default: 'none'
  end
end
