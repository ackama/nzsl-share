class UsersController < ApplicationController
  def show
    @user = policy_scope(User).find(params[:id])
  end
end
