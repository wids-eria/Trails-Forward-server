class ChangePineSawtimberBasePriceInWorld < ActiveRecord::Migration
  def change
    change_column :worlds, :pine_sawtimber_base_price, :float
  end

end
