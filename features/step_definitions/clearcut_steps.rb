Given /^my megatile is completely zoned for logging$/ do
  @my_megatile.resource_tiles.each do |rt|
    rt.zoned_use = ResourceTile.verbiage[:zoned_uses][:logging]
    rt.save!
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
  @my_resource_tile.tree_density.should == 0.0
  @my_resource_tile.tree_size.should == 0.0
end

Then /^my bank balance should increase$/ do
  #is this suppose to be only > or can we have no profit when clearcutting
  @player.balance.should >= @old_balance
end

Given /^the owned megatile is completely zoned for logging$/ do
  @owned_megatile.resource_tiles.each do |rt|
    rt.zoned_use = ResourceTile.verbiage[:zoned_uses][:logging]
    rt.save!
  end
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
    :microtiles => [@my_resource_tile.id]
  decoded = ActiveSupport::JSON.decode(@response.body)
  decoded.has_key?("resource_tiles").should be true
  #decoded["resource_tiles[0]"].has_key?("id").should be true

end

Then /^the list containing that resource tile should have no trees$/ do
  @my_resource_tile.reload
  @my_resource_tile.tree_density.should == 0.0
  @my_resource_tile.tree_size.should == 0.0
end

When /^I clearcut a list containing that resource tile on the owned megatile Then I should get an error$/ do
  @owned_resource_tile = get_clearcuttable_tile @owned_megatile
  lambda {post clearcut_world_resource_tiles_path(@world), :format => :json, :auth_token => @user.authentication_token, :microtiles => [@my_resource_tile.id]}.should raise_error
end

def get_clearcuttable_tile megatile
  resource_tile = megatile.resource_tiles.select(&:can_be_clearcut?).first
  resource_tile.should be
  resource_tile
end
