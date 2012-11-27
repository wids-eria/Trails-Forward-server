class AddTimeToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :time_remaining_this_turn, :integer, :default => 0
  end
end
