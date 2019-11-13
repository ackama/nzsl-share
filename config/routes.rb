Rails.application.routes.draw do
  namespace :admin do
    resources :signs

    root to: "signs#index"
  end

  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  resource :styleguide, only: :show

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq" # monitoring console

  root "home#index"
  resources :search, only: [:index]
  resources :signs, except: %i[index] do
    resource :request_publish, only: %i[create destroy], controller: :sign_request_publish
    resource :publish, only: %i[create destroy], controller: :sign_publish
    resources :videos, param: :preset, only: :show, controller: :sign_video
    resources :share, only: %i[show create destroy], controller: :sign_share, param: :token
    resources :usage_examples, only: %i[destroy], controller: :sign_attachments
    resources :illustrations, only: %i[destroy], controller: :sign_attachments
    resources :sign_attachments, only: %i[create],
                                 path: "/:attachment_type",
                                 as: :attachments,
                                 constraints: { attachment_type: /usage_examples|illustrations/ }
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
