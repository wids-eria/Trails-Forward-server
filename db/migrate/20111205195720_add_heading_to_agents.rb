class AddHeadingToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :heading, :float
  end
end
