class ApplicationController < PublishMyData::ApplicationController
  helper PublishMyData::Engine.helpers
  helper PublishMyDataEnterprise::Engine.helpers
  helper :all
end
