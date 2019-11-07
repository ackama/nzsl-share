Rails.application.routes.draw do
  devise_for :users
  resource :styleguide, only: :show

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" # monitoring console

  root "home#index"
  resources :search, only: [:index]
  resources :signs, except: %i[index] do
    resources :videos, param: :preset, only: :show, controller: :sign_video
    resources :share, only: %i[show create destroy], controller: :sign_share, param: :token
    resources :usage_examples, only: :destroy, controller: :sign_attachments
    resources :illustrations, only: :destroy, controller: :sign_attachments
  end
  resources :topics, only: %i[index show]

  resources :folders do
    resources :share, only: %i[show create destroy], controller: :folder_share, param: :token
  end

  resources :folder_memberships, only: %i[create destroy]
  scope "/user" do
    resources :signs, only: [:index], as: :user_signs
  end
  post "/rails/active_storage/direct_uploads" => "direct_uploads#create"
end
