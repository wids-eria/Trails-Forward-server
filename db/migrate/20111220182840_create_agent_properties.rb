class CreateAgentProperties < ActiveRecord::Migration
  def up
    remove_column :agents, :properties

    create_table :agent_settings do |t|
      t.integer  :agent_id, :null => false
      t.string   :name, :null => false
      t.string   :value
    end

    add_index :agent_settings, [ :agent_id, :name ], :unique => true
  end

  def down
    remove_index :agent_settings, :column => [ :agent_id, :name ]

    drop_table :agent_settings

    add_column :agents, :properties, :text
  end
end
