class DropMegatileRegionCaches < ActiveRecord::Migration
  def up
    drop_table :megatile_region_caches
  end
end
