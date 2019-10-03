Rails.application.routes.draw do
  devise_for :users
  resource :styleguide, only: :show

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" # monitoring console

  root "home#index"
  resources :search, only: [:index]
  resources :signs, only: [:show]
end
