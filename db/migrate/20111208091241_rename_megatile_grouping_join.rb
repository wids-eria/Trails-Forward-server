class RenameMegatileGroupingJoin < ActiveRecord::Migration
  def up
    drop_table :megatile_grouping_megatiles
    create_table :megatile_groupings_megatiles do |t|
      t.integer :megatile_id
      t.integer :megatile_grouping_id
    end
  end

  def down
    drop_table :megatile_groupings_megatiles
    create_table :megatile_grouping_megatiles do |t|
      t.integer :megatile_id
      t.integer :megatile_grouping_id
      t.timestamps
    end
  end
end
