class AddQuestPointsToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :quest_points, :integer, :default => 0
  end
end
