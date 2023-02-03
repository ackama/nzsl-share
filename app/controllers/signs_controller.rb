class SignsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :authenticate_user!, except: %i[show]
  after_action :mark_comments_as_read, only: :show

  def index
    @signs = signs.where(contributor: current_user).page(params[:page])
    authorize @signs
  end

  def show
    @sign = present(signs.includes(sign_comments: :replies).find(id))
    @current_folder_id = params[:comments_in_folder]
    @new_comment = SignComment.new(sign: @sign.sign)
    authorize @sign
    @sign.topic = fetch_referer
    sign_comments

    render
  end

  def new
    return unless check_contribution_limit!

    @sign = Sign.new
    authorize @sign
  end

  def edit
    @sign = signs.find(id)
    authorize @sign
    render
  end

  def create
    @sign = build_sign.sign
    authorize @sign
    return render(:new) unless build_sign.save

    respond_to_create(@sign)
  end

  def update
    @sign = signs.find(id)
    @sign.assign_attributes(edit_sign_params)
    set_signs_submitted_state
    authorize @sign
    return render(:edit) unless @sign.save

    respond_to_update(@sign)
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

    @comments
  end

  def check_contribution_limit!
    return true unless current_user.contribution_limit_reached?

    message = t("users.contribution_limit_reached_html",
                email: Rails.application.config.contact_email)
    redirect_to(root_path, alert: message) && false
  end

  def signs
    sort_by = Sign::SORT_OPTIONS[params[:sort_by].try(:to_sym)] || Sign::SORT_OPTIONS[:alphabetical]
    policy_scope(Sign).for_cards.order(sort_by)
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

  def respond_to_create(sign)
    return redirect_to user_signs_path if params[:batch]

    flash[:notice] = t(".success")

    respond_to do |format|
      format.html { redirect_to edit_sign_path(sign) }
      format.js { render }
    end
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

  def respond_to_update(sign)
    respond_to do |format|
      format.html { redirect_to sign, notice: t(".success") }
      format.js { render inline: "window.location = '#{sign_path(sign)}'" } # rubocop:disable Rails/RenderInline
    end
  end

  def mark_comments_as_read
    return unless user_signed_in?

    @comments.each { |comment| mark_comment_as_read(comment) }
  end

  ## Recursively marks each comment and it's replies (etc)
  # as read.
  def mark_comment_as_read(comment)
    comment.read_by!(current_user)
    comment.replies.each { |reply| mark_comment_as_read(reply) }
  end
end
