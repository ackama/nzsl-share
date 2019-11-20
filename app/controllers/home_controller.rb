# Renders the home page.
class HomeController < ApplicationController
  layout -> { user_signed_in? ? "authenticated_home" : "home" }

  def index
    @recent_signs = policy_scope(Sign).recent.preview
    @viewed_signs = policy_scope(Sign).last(4)
  end
end
