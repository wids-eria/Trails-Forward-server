require 'trails_forward/world_importer'

Given /^no worlds exist$/ do
  World.delete_all
end

Then /^a new world should exist$/ do
  World.count.should > 0
end

Given /^I have a world$/ do
  @world = Factory :world_with_properties_and_users
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

When /^I generate a world from "([^"]*)"$/ do |csv_file_name|
  TrailsForward::WorldImporter.import_world "script/data/#{csv_file_name}", false
end

Then /^the new world should have (\d+) resource tiles$/ do |num_resource_tiles|
  World.last.resource_tiles.count.should == num_resource_tiles.to_i
end

Then /^the new world should have (\d+) megatiles$/ do |num_megatiles|
  World.last.megatiles.count.should == num_megatiles.to_i
end

Then /^the forested resource tiles should have tree bin entries$/ do
  forest_tiles = World.last.resource_tiles.where(landcover_class_code: [41, 42, 43, 90])
  forest_tiles.count.should == 5
  forest_tiles.each do |tile|
    total_trees = (2..24).step(2).map{|n| tile.send("num_#{n}_inch_diameter_trees".to_sym)}.sum
    total_trees.should > 0
  end
end
