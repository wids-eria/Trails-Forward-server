class AddTurnTimestampToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :turn_started_at, :datetime
  end
end
