Given /^I have a player in the world$/ do
  @player = Developer.new do |p|
    p.user = @user
    p.world = @world
    p.balance = Player::DEFAULT_BALANCE
  end
  @player.save!
  @player_initial_balance = @player.balance
end
