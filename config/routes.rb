Rails.application.routes.draw do
  resource :styleguide, only: :show

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" # monitoring console

  root "home#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :search, only: [:index]
  resources :signs, only: [:index]
end
