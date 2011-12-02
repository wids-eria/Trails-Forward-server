class CreateAgents < ActiveRecord::Migration
  def up
    create_table :agents do |t|
      t.string :type
      t.references :world
      t.references :resource_tile
      t.decimal :x
      t.decimal :y
      t.text :properties
    end

    add_index :agents, :type
    add_index :agents, :world_id
    add_index :agents, :resource_tile_id
    add_index :agents, :x
    add_index :agents, :y
  end

  def down
    remove_index :agents, :column => :y
    remove_index :agents, :column => :x
    remove_index :agents, :column => :resource_tile_id
    remove_index :agents, :column => :world_id
    remove_index :agents, :column => :type

    drop_table :agents
  end
end
