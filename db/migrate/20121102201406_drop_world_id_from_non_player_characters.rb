class DropWorldIdFromNonPlayerCharacters < ActiveRecord::Migration
  def change
    remove_column :non_player_characters, :world_id
  end
end
