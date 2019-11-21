class DemographicController < ApplicationController
  def new
    @demographic = policy_scope(Demographic).build
    authorize @demographic

    render
  end

  def create
    @demographic = policy_scope(Demographic).build(demographic_params)
    authorize @demographic

    return render(:new) unless @demographic.save

    redirect_to current_user, notice: t(".success")
  end
end
