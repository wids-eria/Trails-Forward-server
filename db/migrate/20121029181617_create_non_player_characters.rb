class CreateNonPlayerCharacters < ActiveRecord::Migration
  def change
    create_table :non_player_characters do |t|
      t.string :type
      t.integer :world_id
      t.string :name

      t.timestamps
    end
  end
end
