class SignsController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  def show
    @sign = policy_scope(Sign.includes(:contributor, :topic))
            .find(id)
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
      format.html { redirect_to @sign }
      format.js { render inline: "window.location = '#{sign_path(@sign)}'" }
    end
  end

  def edit
    @sign = my_signs.find(id)
    authorize @sign
  end

  def update
    @sign = my_signs.find(id)
    @sign.assign_attributes(create_signs_params)
    authorize @sign
    return render :edit unless @sign.save

    redirect_after_save
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

  def id
    params[:id]
  end
end
