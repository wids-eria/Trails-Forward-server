class AddMegatileToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :megatile_id, :integer
    add_index :surveys, :megatile_id
  end
end
