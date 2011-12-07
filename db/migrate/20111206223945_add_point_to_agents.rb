class AddPointToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :geom, :point, srid: 4326, dimension: 2
    add_index :agents, :geom, spatial: true
  end
end
