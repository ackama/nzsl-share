# frozen_string_literal: true

class SignsController < ApplicationController
  def search
  end

  private

  def sign_params
    params.require(:sign).permit(:english)
  end
end
