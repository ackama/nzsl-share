Rails.application.routes.draw do
  namespace :admin do
    resources :signs
    resources :users
    resources :approved_user_applications, only: %i[index show] do
      member do
        post :accept
        post :decline
      end
    end
    resources :topics
    root to: "signs#index"
  end

  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  resource :styleguide, only: :show
  resources :users, only: :show, param: :username,
                    constraints: {
                      # Route constraints must be unanchored
                      username: Regexp.new(User::USERNAME_REGEXP.source.gsub(/\\A|\\Z/, ""))
                    }

  require "sidekiq/web"
  authenticate :user, ->(u) { u.administrator? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  root "home#index"
  resources :search, only: [:index]
  resources :approved_user_applications, only: %i[new create]
  resources :signs, except: %i[index] do
    resources :share, only: %i[show create destroy], controller: :sign_share, param: :token
    resources :comment, only: %i[create update destroy], controller: :sign_comment do
      patch :appropriate, on: :member
    end
    resources :sign_attachments, only: %i[create update destroy],
                                 path: "/:attachment_type",
                                 as: :attachments,
                                 constraints: { attachment_type: /usage_examples|illustrations/ }
    resource :agreement, only: %i[create destroy], controller: :sign_agreement
    resource :disagreement, only: %i[create destroy], controller: :sign_disagreement
    Sign.aasm.events.map(&:name).each do |event_name|
      patch event_name, on: :member, controller: :sign_workflow
    end
  end

  resources :topics, only: %i[index show]

  resources :folders do
    resources :share, only: %i[show create destroy], controller: :folder_share, param: :token
  end

  get "/videos/:id/:preset" => "videos#show", as: :video

  resources :folder_memberships, only: %i[create destroy]
  scope "/user" do
    resources :signs, only: [:index], as: :user_signs
  end
  post "/rails/active_storage/direct_uploads" => "direct_uploads#create"

  get "/sitemap.xml" => "sitemaps#index", defaults: { format: "xml" }, as: :sitemap
  get "/:page" => "static#show", as: :page
end
