class AddMartenSuitableCountToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :marten_suitable_tile_count, :integer
  end
end
