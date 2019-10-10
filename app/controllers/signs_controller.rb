class SignsController < ApplicationController
  def show
    @sign = policy_scope(Sign.includes(:contributor, :topic))
            .find(params[:id])
    authorize @sign
    return unless stale?(@sign)

    render
  end

  def new
    @sign = policy_scope(Sign).build
    authorize @sign
  end

  def create
    @sign = build_sign
    authorize @sign
    return render(:new) unless @sign.save

    flash[:notice] = t(".success")
    respond_to do |format|
      format.html { redirect_to @sign }
      format.js { render inline: "window.location = '#{sign_path(@sign)}'" }
    end
  end

  private

  def build_sign(builder: SignBuilder.new)
    builder.build(create_sign_params)
  end

  def create_sign_params
    params
      .require(:sign)
      .permit(:video)
      .merge(contributor: current_user)
  end
end
