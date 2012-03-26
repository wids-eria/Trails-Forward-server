When /^I bid on their listing$/ do
  @response = post world_listing_bids_url(@world, @their_listing, :money => 200, :auth_token => @user1.authentication_token, :format => :json)
end

Then /^I should have a bid on that listing$/ do
  @response.status.should == 200
  @my_bid = Bid.last
  @my_bid.listing.should == @their_listing
  @my_bid.bidder.should == @player1
end

Given /^They have a bid on my listing$/ do
  @response = post world_listing_bids_url(@world, @my_listing, :money => 200, :auth_token => @user2.authentication_token, :format => :json)
  @response.status.should == 200
  @their_bid = Bid.last
  @their_bid.listing.should == @my_listing
  @their_bid.bidder.should == @player2
end

When /^I accept a bid on my listing$/ do
  @response = post accept_world_listing_bid_url(@world, @my_listing, @their_bid, :auth_token => @user1.authentication_token, :format => :json)
end

Then /^The bid should be accepted$/ do
  @response.status.should == 200
  Bid.last.accepted?.should be_true
end

Given /^There are two users$/ do
  @player1 = Factory :player, world: @world
  @player2 = Factory :player, world: @world
  @user1 = @player1.user
  @user2 = @player2.user
end

Given /^I have a listing$/ do
  @my_listing = Factory :listing, owner: @player1
end

Given /^They have listing$/ do
  @their_listing = Factory :listing, owner: @player2
end
