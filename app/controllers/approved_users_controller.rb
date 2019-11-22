class ApprovedUsersController < ApplicationController
  before_action :authenticate_user!

  def new
    @user = current_user
    @application = @user.build_approved_user_application
    authorize @application

    render
  end

  def create
    @user = current_user
    @application = @user.build_approved_user_application(application_params)
    authorize @application

    return render(:new) unless @application.save

    ApprovedUserMailer.submitted(self).deliver_later
    redirect_to root_path, notice: t(".success")
  end

  private

  def application_params
    params.require(:application).permit(
      :first_name, :last_name, :gender, :ethnicity,
      :deaf, :nzsl_first_language, :age_bracket, :location,
      :subject_expertise, language_roles: []
    )
  end
end
