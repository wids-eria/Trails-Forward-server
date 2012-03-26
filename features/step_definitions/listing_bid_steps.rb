When /^I bid on their listing$/ do
  @response = post world_listing_bids_url(@world, @listing2, :money => 200, :auth_token => @user1.authentication_token, :format => :json)
end

Then /^I should have a bid on that listing$/ do
  @response.status.should == 200
  @bid = Bid.last
  @bid.listing.should == @listing2
  @bid.owner.should == @player1
end

When /^I accept a bid on my listing$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^The bid should be accepted$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^There are two users$/ do
  @player1 = Factory :player, world: @world
  @player2 = Factory :player, world: @world
  @user1 = @player1.user
  @user2 = @player2.user
end

Given /^I have a listing$/ do
  @listing1 = Factory :listing, owner: @player1
end

Given /^They have listing$/ do
  @listing2 = Factory :listing, owner: @player2
end
