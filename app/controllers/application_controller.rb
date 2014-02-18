class ApplicationController < ActionController::Base
  protect_from_forgery
  helper PublishMyData::Engine.helpers
  helper :all
end
