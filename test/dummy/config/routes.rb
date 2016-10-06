Rails.application.routes.draw do
  mount Totem::Lodestar::Engine => "/"
end
