class AddCurrentTurnToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :current_turn, :integer, default: 0
  end
end
