LinkedDevelopmentPmd::Application.routes.draw do

  get '/', to: redirect('/data'), as: :home # use the data catalogue

  scope '/linked-develpment-api/' do
    get '/docs', to: 'api_doc#index', as: :linked_development_api_docs
  end
  
  mount PublishMyData::Engine, at: "/" 
end
