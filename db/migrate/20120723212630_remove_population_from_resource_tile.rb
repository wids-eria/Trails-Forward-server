class RemovePopulationFromResourceTile < ActiveRecord::Migration
  def up
    remove_column :resource_tiles, :population
  end

  def down
    add_column :resource_tiles, :population, :text
  end
end
