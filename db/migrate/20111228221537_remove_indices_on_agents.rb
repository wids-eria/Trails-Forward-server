class RemoveIndicesOnAgents < ActiveRecord::Migration
  def up
    remove_index :agents, [:resource_tile_id]
    remove_index :agents, [:type]
    remove_index :agents, [:world_id]
    remove_index :agents, [:x]
    remove_index :agents, [:y]

    add_index :agents, [:x, :y, :world_id]
  end

  def down
    remove_index :agents, [:x, :y, :world_id]

    add_index :agents, [:resource_tile_id], :name => "index_agents_on_resource_tile_id"
    add_index :agents, [:type], :name => "index_agents_on_type"
    add_index :agents, [:world_id], :name => "index_agents_on_world_id"
    add_index :agents, [:x], :name => "index_agents_on_x"
    add_index :agents, [:y], :name => "index_agents_on_y"
  end
end
