class AddPendingMoneyToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :pending_balance, :integer, :default => 0
  end
end
