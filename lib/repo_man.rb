class RepoMan
  def self.visit_players! world
    world.players.each do |player|
      visit player
      player.save!
    end
  end

  def self.visit player
    if player.balance < 0
      player.balance = Player.default_balance
      player.logging_equipment = player.logging_equipment.select{|equipment| equipment.name == "Sawyer Crew"}
      player.contracts.delete_all
    end
  end
end
