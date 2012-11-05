class AddWoodChoppedAndUsedThisTurnToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :pine_sawtimber_cut_this_turn, :float, :default => 0
    add_column :worlds, :pine_sawtimber_used_this_turn, :float, :default => 0
  end
end
