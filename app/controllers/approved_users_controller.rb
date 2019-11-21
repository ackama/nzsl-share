class ApprovedUsersController < ApplicationController
  before_action :authenticate_user!

  def new
    @user = current_user
    @demographic = @user.build_demographic
    authorize @demographic

    render
  end

  def create
    @user = current_user
    @demographic = @user.build_demographic(demographic_params)
    authorize @demographic

    return render(:new) unless @demographic.save

    redirect_to root_path, notice: t(".success")
  end

  private

  def demographic_params
    params.require(:demographic).permit(
      :first_name, :last_name, :gender, :ethnicity,
      :deaf, :nzsl_first_language, :age_bracket, :location,
      :subject_expertise, language_roles: []
    )
  end
end
