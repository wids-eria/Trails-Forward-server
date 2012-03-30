class CreateMegatileRegionCaches < ActiveRecord::Migration
  def change
    create_table :megatile_region_caches do |t|
      t.integer :world_id
      t.integer :x_min
      t.integer :x_max
      t.integer :y_min
      t.integer :y_max

      t.timestamps
    end
  end
end
