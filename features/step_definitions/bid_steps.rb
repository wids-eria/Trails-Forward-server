When /^I bid (-?[0-9]+) on the unowned megatile$/ do |money|
  @response = post world_megatile_bids_path(@world, @unowned_megatile),
    :format => :json,
    :auth_token => @user.authentication_token,
    :money => money
end

When /^I bid (-?[0-9]+) on the owned megatile$/ do |money|
  @response = post world_megatile_bids_path(@world, @owned_megatile),
    :format => :json,
    :auth_token => @user.authentication_token,
    :money => money
end

Given /^a bid has been placed on that owned megatile$/ do
  @other_player = @world.players.where(Player.arel_table[:id].not_eq(@player.id)).first

  @other_user = @other_player.user
  @response = post world_megatile_bids_path(@world, @my_megatile),
    :format => :json,
    :auth_token => @other_user.authentication_token,
    :money => 42
  biddata = ActiveSupport::JSON.decode(@response.body)
  biddata.has_key?("bid").should be true
  biddata["bid"].has_key?("id").should be true
  @bid = Bid.find biddata["bid"]["id"]
  @bid.should_not be nil
end

Given /^I can see the bids on that owned megatile$/ do
  @response = get world_megatile_bids_path(@world, @my_megatile),
    :format => :json,
    :auth_token => @user.authentication_token
  bidsdata = ActiveSupport::JSON.decode(@response.body)
  bidsdata.has_key?("bids").should be true

  bidsdata["bids"].each do |biddata|
    biddata.has_key?("id").should be true
    biddata.has_key?("money").should be true
    biddata.has_key?("bidder").should be true
  end
end


Then /^I should get a bid id$/ do
  data = ActiveSupport::JSON.decode(@response.body)
  data.has_key?("bid").should be true
  data["bid"].has_key?("id").should be true
  @bid = Bid.find data["bid"]["id"]
  @bid.should_not be nil
end

Then /^I should not get a bid id$/ do
  #puts "Got a response back with the following body: #{@response.body}"
  data = ActiveSupport::JSON.decode(@response.body)
  data.has_key?("bid").should_not be true
end


When /^I accept the highest dollar bid on that megatile$/ do
  bidsdata = ActiveSupport::JSON.decode(@response.body)

  highest_bid = bidsdata["bids"].first

  bidsdata["bids"].each do |biddata|
    if biddata["money"].to_i > highest_bid["money"].to_i
      highest_bid = biddata
    end
  end

  @winning_bid = Bid.find(highest_bid["id"])

  @response = post world_megatile_bid_accept_path(@world, @my_megatile, @winning_bid),
                :format => :json,
                :auth_token => @user.authentication_token
  @response.status.should be 200
end

Then /^the bidder should own the megatile$/ do
  @my_megatile.reload
  @my_megatile.owner.should_not == @player
  @my_megatile.owner.should == @other_player
end

Then /^my balance should increase by the amount of the bid$/ do
  @player.reload
  (@winning_bid.money + @player_initial_balance).should == @player.balance
end

Then /^The megatile's owner should get an email notification of the bid$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the bidder should get an email notification of the bids acceptance$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^losing bids should be rejected$/ do
  Bid.count.should > 1
  Bid.all.reject {|b| b.rejection_reason}.count.should == 1
end

Then /^the losing bidders should be notified$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see that I have placed that bid$/ do
  @response = get world_player_bids_placed_path(@world, @player),
    :format => :json,
    :auth_token => @user.authentication_token
  bidsdata = ActiveSupport::JSON.decode(@response.body)
  bidsdata.has_key?("bids").should be true

  found_the_bid = false

  bidsdata["bids"].each do |biddata|
    biddata.has_key?("id").should be true
    biddata.has_key?("money").should be true
    biddata.has_key?("bidder").should be true
    if biddata["id"] == @bid.id
      found_the_bid = true
    end
  end
  found_the_bid.should be true
end

Then /^I should see that I have received that bid$/ do
  @response = get world_player_bids_received_path(@world, @player),
    :format => :json,
    :auth_token => @user.authentication_token,
    :active => "Yep"
  bidsdata = ActiveSupport::JSON.decode(@response.body)
  bidsdata.has_key?("bids").should be true

  found_the_bid = false

  bidsdata["bids"].each do |biddata|
    biddata.has_key?("id").should be true
    biddata.has_key?("money").should be true
    biddata.has_key?("bidder").should be true
    if biddata["id"] == @bid.id
      found_the_bid = true
    end
  end
  found_the_bid.should be true
end

