class AddDesirabilityScoresToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :local_desirability_score, :float, :default => 0
    add_column :resource_tiles, :total_desirability_score, :float, :default => 0
  end
end
