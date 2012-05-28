class AddPopulationToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :population, :text
  end
end
