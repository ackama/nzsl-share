class SignsController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  def show
    @sign = present(signs.includes(sign_comments: :replies).find(id))
    @current_folder_id = params[:comments_in_folder]
    @new_comment = SignComment.new(sign: @sign.sign)
    authorize @sign
    @sign.topic = fetch_referer
    sign_comments

    render
  end

  def index
    @signs = signs.where(contributor: current_user)
    authorize @signs
  end

  def new
    return unless check_contribution_limit!

    @sign = Sign.new
    authorize @sign
  end

  def create
    @sign = build_sign.sign
    authorize @sign
    return render(:new) unless build_sign.save

    flash[:notice] = t(".success")
    respond_to do |format|
      format.html { redirect_to [:edit, @sign] }
      format.js { render inline: "window.location = '#{edit_sign_path(@sign)}'" }
    end
  end

  def edit
    @sign = signs.find(id)
    authorize @sign
    render
  end

  def update
    @sign = signs.find(id)
    @sign.assign_attributes(edit_sign_params)
    set_signs_submitted_state
    authorize @sign
    return render(:edit) unless @sign.save

    redirect_after_update(@sign)
  end

  def destroy
    @sign = signs.find(id)
    authorize @sign
    @sign.destroy
    redirect_to user_signs_path, notice: t(".success", sign_name: @sign.word)
  end

  private

  def fetch_referer
    request.referer ? URI(request.referer).path : nil
  end

  def sign_comments
    @comments = policy_scope(@sign.sign_comments)
                .includes(:replies, user: :avatar_attachment).where(folder_id: comments_folder_id)
                .page(params[:comments_page]).per(10)
  end

  def check_contribution_limit!
    return true unless current_user.contribution_limit_reached?

    message = t("users.contribution_limit_reached_html",
                email: Rails.application.config.contact_email)
    redirect_to(root_path, alert: message) && false
  end

  def signs
    policy_scope(Sign).for_cards.order(word: :asc)
  end

  def build_sign(builder: SignBuilder.new)
    @build_sign ||= builder.build(create_sign_params)
  end

  def create_sign_params
    params.require(:sign).permit(:video).merge(contributor: current_user)
  end

  def edit_sign_params
    params.require(:sign).permit(:maori, :secondary, :notes, :word, :usage_examples, :illustrations,
                                 :conditions_accepted, topic_ids: [])
  end

  def id
    params[:id]
  end

  def comments_folder_id
    fallback = @sign.published? || @sign.unpublish_requested? ? nil : policy_scope(@sign.folders).first
    params[:comments_in_folder].presence || fallback
  end

  def set_signs_submitted_state
    return unless params[:should_submit_for_publishing]

    if params[:should_submit_for_publishing] == "false"
      authorize(@sign, :cancel_submit?)
      @sign.cancel_submit
    elsif params[:should_submit_for_publishing] == "true" && !@sign.submitted?
      authorize(@sign, :submit?)
      @sign.submit
    end
  end

  def redirect_after_update(sign)
    respond_to do |format|
      format.html { redirect_to sign, notice: t(".success") }
      format.js { render inline: "window.location = '#{sign_path(sign)}'" }
    end
  end
end
