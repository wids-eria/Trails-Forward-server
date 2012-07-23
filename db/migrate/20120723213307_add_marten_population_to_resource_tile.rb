class AddMartenPopulationToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :marten_population, :float, default: 0.0
  end
end
