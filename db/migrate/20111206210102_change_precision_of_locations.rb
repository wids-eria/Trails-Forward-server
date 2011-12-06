class ChangePrecisionOfLocations < ActiveRecord::Migration
  def up
    change_column :agents, :x, :float
    change_column :agents, :y, :float
    change_column :agents, :heading, :integer
  end

  def down
    change_column :agents, :heading, :float
    change_column :agents, :y, :decimal
    change_column :agents, :x, :decimal
  end
end
