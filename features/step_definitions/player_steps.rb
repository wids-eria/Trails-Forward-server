Given /^I have a player in the world$/ do
  @player = @world.players.first
  @player.user = @user
  @player.save!
  @player_initial_balance = @player.balance
end
