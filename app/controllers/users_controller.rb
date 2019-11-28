class UsersController < ApplicationController
  def show
    @user = policy_scope(User).find_by!(username: params[:username])
  end
end
