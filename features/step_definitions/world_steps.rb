Given /^I have a world$/ do
  @world = Factory :world_with_properties
end

Given /^I have an unowned megatile in the world$/ do
  @unowned_megatile = @world.megatiles.where(:owner_id => nil).first
end

Given /^I have an owned megatile in the world$/ do
  @owned_megatile = @world.megatiles.where(:owner_id => nil).last
  @owned_megatile.owner = @world.players.where('id <> ?', @player.id).first #anybody but me
  @owned_megatile.save!
end

Given /^I own a megatile in the world$/ do
  @my_megatile = @world.megatiles.where(:owner_id => nil).last
  @my_megatile.owner = @player
  @my_megatile.save!
end


