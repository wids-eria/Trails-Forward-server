class DropHousingCapacityHousingDensityPeopleDensityAddHousingTypeToResourceTile < ActiveRecord::Migration
  def change
    remove_column :resource_tiles, :housing_density
    remove_column :resource_tiles, :people_density
    remove_column :resource_tiles, :housing_capacity
    add_column :resource_tiles, :housing_type, :string
  end

end
