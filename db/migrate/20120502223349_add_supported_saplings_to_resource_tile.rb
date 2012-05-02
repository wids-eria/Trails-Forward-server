class AddSupportedSaplingsToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :supported_saplings, :integer, :default => 0
  end
end
