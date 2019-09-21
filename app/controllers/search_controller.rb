# frozen_string_literal: true

class SearchController < ApplicationController
  def index
  end

  private

  def search_params
    params.require(:search).permit(:word)
  end
end
