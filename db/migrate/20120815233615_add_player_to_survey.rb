class AddPlayerToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :player_id, :integer
    add_index :surveys, :player_id
  end
end
