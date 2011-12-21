class AddAgeToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :age, :integer, default: 0
  end
end
