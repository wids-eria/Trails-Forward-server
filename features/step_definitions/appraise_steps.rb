Given /^at least one resource tile on the megatile is a land type$/ do
  @my_megatile.resource_tiles.each do |rt|
    rt.type = LandTile.to_s
    rt.save!
  end
end

Given /^at least one resource tile on the owned megatile is a land type$/ do
  @owned_megatile.resource_tiles.each do |rt|
    rt.type = LandTile.to_s
    rt.save!
  end
end

When /^I appraise a megatile that I own$/ do
  @response = get appraise_world_megatile_path(@world, @my_megatile), 
    :format => :json, 
    :auth_token => @user.authentication_token
  decoded = ActiveSupport::JSON.decode(@response.body)
  decoded.has_key?("megatile").should be true
  @result = decoded
end

Then /^the estimated value for the megatile should be greater than zero$/ do
  (@result["megatile"])["estimated_value"].should > 0.0
end


When /^I appraise the megatile on the owned megatile$/ do
  @response = get appraise_world_megatile_path(@world, @owned_megatile), 
    :format => :json, 
    :auth_token => @user.authentication_token
  decoded = ActiveSupport::JSON.decode(@response.body)
  decoded.has_key?("megatile").should be true
  @result = decoded
end

When /^I appraise a list containing the megatile that I own$/ do
  @response = get appraise_world_megatiles_path(@world), 
    :format => :json, 
    :auth_token => @user.authentication_token,
    :megatiles => [@my_megatile.id]
  decoded = ActiveSupport::JSON.decode(@response.body)
  decoded.has_key?("megatiles").should be true
  @result = decoded
end


Then /^the estimated value for the list of megatile should be greater than zero$/ do
  ((@result["megatiles"])[0])["estimated_value"].should > 0.0
end


When /^I appraise a list containing that megatile on the owned megatile$/ do
  @response = get appraise_world_megatiles_path(@world), 
    :format => :json, 
    :auth_token => @user.authentication_token,
    :megatiles => [@owned_megatile.id]
  decoded = ActiveSupport::JSON.decode(@response.body)
  decoded.has_key?("megatiles").should be true
  @result = decoded
end

