class AddTurnDurationToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :turn_duration, :integer, default: 15
  end
end
