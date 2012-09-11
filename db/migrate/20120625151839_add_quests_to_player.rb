class AddQuestsToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :quests, :string
  end
end
