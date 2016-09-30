Rails.application.routes.draw do
  mount Totem::Lodestar::Engine => "/totem-lodestar"
end
