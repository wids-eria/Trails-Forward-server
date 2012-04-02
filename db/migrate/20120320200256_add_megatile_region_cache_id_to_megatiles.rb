class AddMegatileRegionCacheIdToMegatiles < ActiveRecord::Migration
  def change
    add_column :megatiles, :megatile_region_cache_id, :integer
  end
end
