class AddGeomToResourceTiles < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :geom, :point, srid: 4326, dimension: 2
    add_index :resource_tiles, :geom, spatial: true
  end
end
