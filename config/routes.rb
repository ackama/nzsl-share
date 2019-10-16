Rails.application.routes.draw do
  devise_for :users
  resources :folders
  resource :styleguide, only: :show

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" # monitoring console

  root "home#index"
  resources :search, only: [:index]
  resources :signs, only: %i[show new create]
  resources :topics, only: %i[index show]
  resources :folder_memberships, only: %i[create destroy]
  post "/rails/active_storage/direct_uploads" => "direct_uploads#create"
end
