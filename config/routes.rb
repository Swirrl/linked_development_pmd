LinkedDevelopmentPmd::Application.routes.draw do

  get '/', to: 'api_doc#home', as: :home # use the data catalogue

  scope '/linked-develpment-api' do
    get '/', to: 'api_doc#overview', as: :linked_development_overview_docs
    get '/docs', to: 'api_doc#index', as: :linked_development_api_docs
    get '/source_code', to: 'api_doc#source_code', as: :linked_development_source_code
    get '/privacy_policy', to: 'api_doc#privacy_policy', as: :linked_development_privacy_policy
    get '/accessibility_policy', to: 'api_doc#accessibility_policy', as: :linked_development_accessibility_policy
  end

  mount PublishMyDataEnterprise::Engine, at: "/" , as: 'publish_my_data_enterprise'
  mount PublishMyData::Engine, at: "/", as: 'publish_my_data'
end
