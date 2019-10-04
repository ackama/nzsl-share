class ApplicationController < ActionController::Base
  include Pundit
  before_action :http_basic_auth
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout -> { user_signed_in? ? "authenticated" : "application" }

  protected

  def configure_permitted_parameters
    sign_in_attrs = %i[username email password password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: sign_in_attrs + [:remember_me]
    devise_parameter_sanitizer.permit :account_update, keys: sign_in_attrs
  end

  private

  def http_basic_auth
    return unless ENV["HTTP_BASIC_AUTH_USERNAME"] && ENV["HTTP_BASIC_AUTH_PASSWORD"]

    authenticate_or_request_with_http_basic("Username and Password please") do |username, password|
      username == ENV["HTTP_BASIC_AUTH_USERNAME"] && password == ENV["HTTP_BASIC_AUTH_PASSWORD"]
    end
  end
end
