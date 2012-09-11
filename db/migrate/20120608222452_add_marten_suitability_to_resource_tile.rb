class AddMartenSuitabilityToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :marten_suitability, :integer
  end
end
