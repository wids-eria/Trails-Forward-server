class AddHousingFieldsToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :housing_capacity, :integer, :default => 0
    add_column :resource_tiles, :housing_occupants, :integer, :default => 0
  end
end
