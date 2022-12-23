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
    resources :comment_reports
    resources :exports, only: :index do
      get :published_signs, on: :collection
      get :users, on: :collection
    end
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
  resources :public_signs, only: [:index]
  resources :approved_user_applications, only: %i[new create]
  resources :signs, except: %i[index] do
    resources :share, only: %i[show create destroy], controller: :sign_share, param: :token
    resources :comments, only: %i[create edit update destroy], controller: :sign_comments do
      resources :reports, only: :create, controller: :comment_reports
      resource :video, only: %i[update destroy], controller: :sign_video_comment
    end
    resources :video_comment, only: %i[create], controller: :sign_video_comment
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
    resources :collaborations, controller: :collaborations
  end

  get "/videos/:id/:preset" => "videos#show", as: :video

  resources :folder_memberships, only: %i[create destroy]

  scope "/user" do
    resources :signs, only: [:index], as: :user_signs
  end
  post "/rails/active_storage/direct_uploads" => "direct_uploads#create"

  ##
  # Workaround a "bug" in lighthouse CLI
  #
  # Lighthouse CLI (versions 5.4 - 5.6 tested) issues a `GET /asset-manifest.json`
  # request during its run - the URL seems to be hard-coded. This file does not
  # exist so, during tests, your test will fail because rails will die with a 404.
  #
  # Lighthouse run from Chrome Dev-tools does not have the same behaviour.
  #
  # This hack works around this. This behaviour might be fixed by the time you
  # read this. You can check by commenting out this block and running the
  # accessibility and performance tests. You are encouraged to remove this hack
  # as soon as it is no longer needed.
  #
  if defined?(Webpacker) && Rails.env.test?
    # manifest paths depend on your webpacker config so we inspect it
    manifest_path = Webpacker::Configuration
                    .new(root_path: Rails.root, config_path: Rails.root.join("config/webpacker.yml"), env: Rails.env)
                    .public_manifest_path
                    .relative_path_from(Rails.public_path)
                    .to_s
    get "/asset-manifest.json", to: redirect(manifest_path)
  end

  get "/sitemap.xml" => "sitemaps#index", defaults: { format: "xml" }, as: :sitemap

  # This route acts as a catch-all, and so should always be placed at the end of the routes declaration
  # block
  get "/:page" => "static#show", as: :page
end
