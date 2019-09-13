Rails.application.routes.draw do
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" # monitoring console
  root "home#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get "signs/search", to: "signs#search"
end
