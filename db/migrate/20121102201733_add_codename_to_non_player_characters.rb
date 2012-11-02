class AddCodenameToNonPlayerCharacters < ActiveRecord::Migration
  def change
    add_column :non_player_characters, :codename, :string
  end
end
