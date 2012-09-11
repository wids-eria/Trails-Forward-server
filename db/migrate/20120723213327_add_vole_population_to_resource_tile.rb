class AddVolePopulationToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :vole_population, :float, default: 0.0
  end
end
