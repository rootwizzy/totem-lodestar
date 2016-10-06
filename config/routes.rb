Totem::Lodestar::Engine.routes.draw do
  root to: 'versions#index'
  get '/*version_id/:section_id/:document_id', to: 'documents#show', as: 'document'
  get '/*version_id/:section_id',              to: redirect('/%{version_id}'), as: 'section'
  get '/*version_id',                          to: 'versions#show', format: false, as: 'version'
end
