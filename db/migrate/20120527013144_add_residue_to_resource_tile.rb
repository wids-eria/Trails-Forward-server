class AddResidueToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :residue, :text
  end
end
