Totem::Lodestar::Engine.routes.draw do
  root to: 'versions#index'

  get '/api/:api_id', to: 'api#show'
  get '/api/:api_id/*file', to: 'api#show', as: 'api'
  # get '/api', to: 'api#index'

  get '/*version_id/:section_id/:document_id', to: 'documents#show', as: 'document'
  get '/*version_id/:section_id',              to: redirect('/%{version_id}'), as: 'section'
  get '/*version_id',                          to: 'versions#show', format: false, as: 'version'

end
