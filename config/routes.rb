# -*- coding: utf-8 -*-
LinkedDevelopmentPmd::Application.routes.draw do

  match "/" => redirect('/data'), :as => 'home' # don't call this root - having two routes confuses devise (there's one in pmd_enterprise too).

  scope '/api' do
    get '/docs', to: 'api_doc#index', as: :api_docs
  end

  mount PublishMyDataEnterprise::Engine, at: "/" , as: 'publish_my_data_enterprise'
  mount PublishMyData::Engine, at: "/"
  
end
