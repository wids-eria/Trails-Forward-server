class AddTimestampsToMegatile < ActiveRecord::Migration
  def change
    change_table :megatiles do |t|
      t.timestamps
    end
  end
end
