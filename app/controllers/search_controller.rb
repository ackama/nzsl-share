# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @results = SearchService.call(search: new_search).data
    render template: "home/results"
  end

  private

  def new_search
    Search.new(search_params)
  end

  def search_params
    params.require(:search).permit(:word)
  end
end
