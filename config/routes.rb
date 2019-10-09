Rails.application.routes.draw do
  devise_for :users
  resources :folders
  resource :styleguide, only: :show

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" # monitoring console

  root "home#index"
  resources :search, only: [:index]
  resources :signs, only: [:show]
  resources :topics, only: %i[index show]
  resources :folder_memberships, only: %i[create destroy]
end
