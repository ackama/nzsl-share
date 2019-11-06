# Renders the home page.
class HomeController < ApplicationController
  def index
    @signs = policy_scope(Sign).first(4)
  end
end
