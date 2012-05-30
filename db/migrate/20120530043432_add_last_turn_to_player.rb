class AddLastTurnToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :last_turn_played, :integer, default: 0
  end
end
