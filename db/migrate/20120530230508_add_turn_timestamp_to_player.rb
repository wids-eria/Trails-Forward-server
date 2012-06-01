class AddTurnTimestampToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :last_turn_played_at, :datetime
  end
end
