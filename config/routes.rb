Totem::Lodestar::Engine.routes.draw do
  ## root
  root to: 'versions#index'
  ## site/v0.1.0/foo/bar
  get '/*version_id/:section_id/:document_id', to: 'documents#show', as: 'document'
  ## site/v0.1.0/foo --> site/v0.1.0
  get '/*version_id/:section_id',              to: redirect('/%{version_id}'), as: 'section'
  ## site/v0.1.0
  get '/*version_id',                          to: 'versions#show', format: false, as: 'version'
end
