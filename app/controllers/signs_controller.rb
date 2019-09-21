# frozen_string_literal: true

class SignsController < ApplicationController
  def index
  end

  private

  def sign_params
    params.require(:sign).permit(:english, :maori)
  end
end
