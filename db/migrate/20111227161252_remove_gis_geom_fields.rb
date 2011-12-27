class RemoveGisGeomFields < ActiveRecord::Migration
  def change
    remove_index :agents, :geom
    remove_column :agents, :geom

    remove_index :resource_tiles, :geom
    remove_column :resource_tiles, :geom
  end
end
