class CreateResourcesTable < ActiveRecord::Migration
  def up
    create_table :resources do |t|
      t.string :type
      t.float :value
      t.references :world
      t.references :resource_tile
    end
  end

  def down
    drop_table :resources
  end
end
