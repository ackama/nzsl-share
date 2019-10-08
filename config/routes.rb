Rails.application.routes.draw do
  devise_for :users

  resources :folders do
    member do
      patch :share
      put :share
    end
  end

  resource :styleguide, only: :show

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" # monitoring console

  root "home#index"
  resources :search, only: [:index]
  resources :signs, only: [:show]
  resources :topics, only: %i[index show]
end
