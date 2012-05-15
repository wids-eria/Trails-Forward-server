Given /^I have a player in the world$/ do
  @player = @world.players.first
  @player.user = @user
  @player.save!
  @player_initial_balance = @player.balance
end


When /^I create a developer in the world$/ do
  @response = post world_players_path(@world), :format => :json, :auth_token => @user.authentication_token
end


Then /^That player will be assigned to me$/ do
  player_data = ActiveSupport::JSON.decode(@response.body)
  player = Player.find player_data["player"]["id"]
  player.user.should == @user
  player.world.should == @world
end
