Given /^I have one user "([^"]*)" with password "([^"]*)"$/ do |email, password|
  @user_password = password
  @user = Factory(:user, :email => email, :name => "Test User #{rand(420)}", :password => password, :password_confirmation => password)
end

Given /^I have a user$/ do
  @user = Factory :user
end

When /^I submit the user's email and password to the users_authenticate_for_token url$/ do
  @response = post users_authenticate_for_token_path, :format => :json, :email => @user.email, :password => @user_password
end

Then /^I should get the user's authentication token$/ do
  data = ActiveSupport::JSON.decode(@response.body)
  data["auth_token"].should == @user.authentication_token
end

When /^I submit the user's email and incorrect password to the users_authenticate_for_token url$/ do
  @response = post users_authenticate_for_token_path, :format => :json, :email => @user.email, :password => (@user_password*2)
end

Then /^I should not get the user's authentication token$/ do
  @response.status.should == 403
end
