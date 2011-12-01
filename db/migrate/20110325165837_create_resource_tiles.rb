class CreateResourceTiles < ActiveRecord::Migration
  def self.up
    create_table :resource_tiles do |t|
      t.integer :megatile_id
      t.integer :x
      t.integer :y
      t.string :type
      t.string :zoned_use

      t.integer :quality

      t.string :species

      t.timestamps
    end
  end

  def self.down
    drop_table :resource_tiles
  end
end
