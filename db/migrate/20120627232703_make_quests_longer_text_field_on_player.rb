class MakeQuestsLongerTextFieldOnPlayer < ActiveRecord::Migration
  def up
    change_column :players, :quests, :text
  end

  def down
    change_column :players, :quests, :string
  end
end
