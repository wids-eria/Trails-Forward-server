Given /^my megatile is completely zoned for logging$/ do
  @my_megatile.resource_tiles.each do |rt|
    rt.zoned_use = ResourceTile::Verbiage[:zoned_uses][:logging]
    rt.save!
  end
end


When /^I clearcut a resource tile on the megatile that I own$/ do
  @my_resource_tile = @my_megatile.resource_tiles.first
  @response = post clearcut_world_resource_tile_path(@world, @my_resource_tile), 
    :format => :json, 
    :auth_token => @user.authentication_token
  decoded = ActiveSupport::JSON.decode(@response.body)
  decoded.has_key?("resource_tile").should be true
  decoded["resource_tile"].has_key?("id").should be true
end

Then /^that resource tile should have no trees$/ do
  @my_resource_tile = ResourceTile.find @my_resource_tile.id
  @my_resource_tile.tree_density.should be 0.0
  @my_resource_tile.tree_size.should be 0.0
end

Then /^my bank balance should increase$/ do
  pending # express the regexp above with the code you wish you had
end
