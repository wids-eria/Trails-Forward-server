class RemoveResidueFromResourceTile < ActiveRecord::Migration
  def up
    remove_column :resource_tiles, :residue
  end

  def down
    add_column :resource_tiles, :residue, :text
  end
end
