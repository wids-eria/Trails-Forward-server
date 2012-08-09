class AddUpdatedAtIndexToMegatile < ActiveRecord::Migration
  def change
    add_index :megatiles, [:world_id, :updated_at]
  end
end
