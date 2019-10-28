# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    service = SearchService.call(search: new_search)

    @signs = service.data
    @page = service.support
  end

  private

  def new_search
    Search.new(search_params)
  end

  def search_params
    params.permit(:word, :page, order: %i[published word])
  end
end
