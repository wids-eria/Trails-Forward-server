class AddWoodPricingCoefficientsToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :pine_sawtimber_base_price, :integer
    add_column :worlds, :pine_sawtimber_supply_coefficient, :float
    add_column :worlds, :pine_sawtimber_demand_coefficient, :float
    add_column :worlds, :pine_sawtimber_min_price, :integer
    add_column :worlds, :pine_sawtimber_max_price, :integer
  end
end
