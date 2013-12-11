LinkedDevelopmentPmd::Application.routes.draw do
  match "/" => "home#index", :as => 'home' # don't call this root - having two routes confuses devise (there's one in pmd_enterprise too).

  mount PublishMyDataEnterprise::Engine, at: "/" , as: 'publish_my_data_enterprise'
  mount PublishMyData::Engine, at: "/"
end
