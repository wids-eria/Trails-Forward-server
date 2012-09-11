class AddCompletedQuestsToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :completed_quests, :string
  end
end
