class ChangePlayerBalanceDefaultToZero < ActiveRecord::Migration
  def up
    change_column :players, :balance, :integer, :default => 0
  end

  def down
    change_column :players, :balance, :integer
  end
end
