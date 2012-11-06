Given /^my megatile is completely zoned for logging$/ do
  # TODO:re-visit how this should be set up
  # @my_megatile.resource_tiles.each do |rt|
    # rt.update_attributes(zoned_use: logging_zone) if rt.zone_allowed? logging_zone
  # end
end

Given /^the owned megatile is completely zoned for logging$/ do
  @owned_megatile.resource_tiles.each do |rt|
    rt.update_attributes(zoning_code: 6) # if rt.zone_allowed? logging_zone
  end
end

When /^I clearcut a resource tile on the megatile that I own$/ do
  @my_resource_tile = get_clearcuttable_tile @my_megatile
  @old_balance = @player.balance
  @response = post clearcut_world_resource_tile_path(@world, @my_resource_tile),
    :format => :json,
    :auth_token => @user.authentication_token
  decoded = ActiveSupport::JSON.decode(@response.body)
  decoded.has_key?("resource_tile").should be true
  decoded["resource_tile"].has_key?("id").should be true
end

Then /^that resource tile should have no trees$/ do
  @my_resource_tile.reload
  @my_resource_tile.collect_tree_size_counts.map(&:to_i).should == Array.new(12,0)
end

Then /^my bank balance should increase$/ do
  #is this suppose to be only > or can we have no profit when clearcutting
  @player.balance.should >= @old_balance
end

When /^I clearcut a resource tile on the owned megatile Then I should get an error$/ do
  @owned_resource_tile = get_clearcuttable_tile @owned_megatile
  lambda {post clearcut_world_resource_tile_path(@world, @owned_resource_tile), :format => :json, :auth_token => @user.authentication_token}.should raise_error
end

When /^I clearcut a list containing that resource tile on the megatile that I own$/ do
  @my_resource_tile = get_clearcuttable_tile @my_megatile
  @old_balance = @player.balance

#  @response = post clearcut_world_resource_tile_path(@world, @my_resource_tile),
#    :format => :json,
#    :auth_token => @user.authentication_token

  @response = post clearcut_world_resource_tiles_path(@world),
    :format => :json,
    :auth_token => @user.authentication_token,
    :resource_tile_ids => [@my_resource_tile.id]
  decoded = ActiveSupport::JSON.decode(@response.body)
  #decoded["resource_tiles[0]"].has_key?("id").should be true
end

Then /^the list containing that resource tile should have no trees$/ do
  @my_resource_tile.reload
  @my_resource_tile.collect_tree_size_counts.should == Array.new(12,0)
end

When /^I clearcut a list containing that resource tile on the owned megatile Then I should get an error$/ do
  @owned_resource_tile = get_clearcuttable_tile @owned_megatile
  lambda {post clearcut_world_resource_tiles_path(@world), :format => :json, :auth_token => @user.authentication_token, :resource_tile_ids => [@my_resource_tile.id]}.should raise_error
end

def get_clearcuttable_tile megatile
  resource_tile = megatile.resource_tiles.select(&:can_harvest?).first
  resource_tile.should be
  resource_tile
end
