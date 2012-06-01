class SetWorldTurnDefault < ActiveRecord::Migration
  def up
    change_column :worlds, :current_turn, :integer, :default => 1
  end

  def down
    change_column :worlds, :current_turn, :integer, :default => 0
  end
end
