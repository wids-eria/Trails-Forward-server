class AddStateToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :state, :string
  end
end
