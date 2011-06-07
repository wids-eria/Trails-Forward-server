class ApplicationController < ActionController::Base
  protect_from_forgery
  #turn this on once we've added the perms stuff
  check_authorization :unless => :devise_controller?
end
