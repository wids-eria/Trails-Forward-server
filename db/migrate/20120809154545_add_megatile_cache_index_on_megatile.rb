class AddMegatileCacheIndexOnMegatile < ActiveRecord::Migration
  def change
    add_index :megatiles, [:megatile_region_cache_id, :updated_at]
  end
end
