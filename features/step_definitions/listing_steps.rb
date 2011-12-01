Given /^there is a listing for that owned megatile$/ do
  mtg = MegatileGrouping.create
  mtg.megatiles << @owned_megatile

  @listing = Listing.new do |l|
    l.owner = @owned_megatile.owner
    l.price = 30
    l.megatile_grouping = mtg
  end
  @listing.save!
end

When /^I retrieve the active listings for the world$/ do
  @response = get active_world_listings_path(@world),
    :format => :json,
    :auth_token => @user.authentication_token
  @listingsdata = ActiveSupport::JSON.decode(@response.body)
  @listingsdata.has_key?("listings").should be true
end

Then /^I should see the megatile listed for sale$/ do
  listing_found = false
  @listingsdata["listings"].each do |listingdata|
    if listingdata["id"] == @listing.id
      listing_found = true
    end
  end
  listing_found.should be true
end

When /^I list my megatile for sale$/ do
  @response = post world_listings_path(@world),
    :format => :json,
    :auth_token => @user.authentication_token,
    :price => 32,
    :megatiles => [@my_megatile.id]
  decoded = ActiveSupport::JSON.decode(@response.body)
  decoded.has_key?("listing").should be true
  decoded["listing"].has_key?("id").should be true
end

Then /^I should see my megatile listed for sale$/ do
  listing_found = false
  @listingsdata["listings"].each do |listingdata|
    listingdata["megatiles"].each do |mt_data|
      if mt_data["id"] == @my_megatile.id
        listing_found = true
      end
    end
  end
  listing_found.should be true
end
