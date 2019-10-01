# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @results = SearchService.call(search: new_search)
  end

  private

  def new_search
    Search.new(search_params)
  end

  def search_params
    params.permit(:word, :published, :page)
  end
end
