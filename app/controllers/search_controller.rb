# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    service = SearchService.call(search: new_search, scope: SignPolicy::Scope.new(current_user, Sign).search)

    @signs = service.data
    @page = service.support
  end

  private

  def new_search
    Search.new(search_params)
  end

  def search_params
    { term: params.require(:term) }.merge(params.permit(:page, :sort))
  end
end
