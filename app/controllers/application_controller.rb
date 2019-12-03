class ApplicationController < ActionController::Base
  include Pundit
  include ActiveStorage::SetCurrent
  include PresentersHelper

  before_action :store_user_location!, if: :storable_location?
  before_action :http_basic_auth
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout -> { user_signed_in? ? "authenticated" : "application" }

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  protected

  ##
  # Rails' built in stale? caching helper method does not
  # respect whether caching is enabled or not.
  # While this is a different kind of cahing, it is unexpected
  # for an action to be served with 304 status in a development
  # or test environment.
  def stale?(*args)
    return true unless perform_caching

    super
  end

  def configure_permitted_parameters
    sign_in_attrs = %i[username email password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: sign_in_attrs + %i[remember_me bio]
    devise_parameter_sanitizer.permit :account_update, keys: sign_in_attrs + %i[bio avatar]
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    redirect_back fallback_location: root_path,
                  alert: t("application.unauthorized")
  end

  def http_basic_auth
    return unless ENV["HTTP_BASIC_AUTH_USERNAME"] && ENV["HTTP_BASIC_AUTH_PASSWORD"]

    authenticate_or_request_with_http_basic("Username and Password please") do |username, password|
      username == ENV["HTTP_BASIC_AUTH_USERNAME"] && password == ENV["HTTP_BASIC_AUTH_PASSWORD"]
    end
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && !user_signed_in?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end
end
