class AddTurnStateToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :turn_state, :string, default: 'play'
  end
end
