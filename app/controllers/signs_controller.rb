class SignsController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  def show
    @sign = present(policy_scope(Sign.includes(:contributor, :topic))
            .find(params[:id]))
    authorize @sign
    return unless stale?(@sign)

    render
  end

  def index
    authorize my_signs
  end

  def new
    @sign = Sign.new
    authorize @sign
  end

  def create
    builder = build_sign
    @sign = builder.sign
    authorize @sign
    return render(:new) unless builder.save

    flash[:notice] = t(".success")

    respond_to do |format|
      format.html { redirect_to [:edit, @sign] }
      format.js { render inline: "window.location = '#{edit_sign_path(@sign)}'" }
    end
  end

  def edit
    @sign = present(my_signs.find(params[:id]))
    authorize @sign

    render
  end

  def update # rubocop:disable Metrics/AbcSize
    @sign = present(my_signs.find(id))
    @sign.assign_attributes(edit_sign_params)
    set_signs_submitted_state if params["should_submit_for_publishing"]
    authorize @sign
    return render(:edit) unless @sign.save

    flash[:notice] = t(".success")
    redirect_after_update(@sign)
  end

  private

  def my_signs
    @signs = policy_scope(Sign.where(contributor: current_user)).order(word: :asc)
  end

  def build_sign(builder: SignBuilder.new)
    builder.build(create_sign_params)
  end

  def create_sign_params
    params
      .require(:sign)
      .permit(:video)
      .merge(contributor: current_user)
  end

  def edit_sign_params
    params
      .require(:sign)
      .permit(:video, :maori, :secondary, :notes, :word, :topic_id)
      .merge(contributor: current_user)
  end

  def id
    params[:id]
  end

  def set_signs_submitted_state
    @sign.submit_for_publishing! if params["should_submit_for_publishing"] == "true"
    @sign.set_sign_to_personal! if params["should_submit_for_publishing"] == "false"
  end

  def redirect_after_update(sign)
    respond_to do |format|
      format.html { redirect_to sign }
      format.js { render inline: "window.location = '#{sign_path(sign)}'" }
    end
  end
end
