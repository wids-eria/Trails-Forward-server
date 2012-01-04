class AddZoningCodeToResourceTiles < ActiveRecord::Migration
  def up
    add_column :resource_tiles, :zoning_code, :integer
    remove_column :resource_tiles, :zoned_use
  end
  def down
    add_column :resource_tiles, :zoned_use, :string
    remove_column :resource_tiles, :zoning_code
  end
end
