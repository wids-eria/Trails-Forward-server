class RemoveCompletedQuestsFromPlayer < ActiveRecord::Migration
  def up
    remove_column :players, :completed_quests
  end

  def down
    add_column :players, :completed_quests, :string
  end
end
