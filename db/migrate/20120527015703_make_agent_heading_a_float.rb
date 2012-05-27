class MakeAgentHeadingAFloat < ActiveRecord::Migration
  def up
    change_column :agents, :heading, :float
  end

  def down
    change_column :agents, :heading, :integer
  end
end
