class AddPointToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :geom, :point, srid: 4326
    add_index :agents, :geom, spacial: true
  end
end
