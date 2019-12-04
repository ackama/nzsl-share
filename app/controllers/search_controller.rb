# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @signs = search_results.data
    @freelex_signs = freelex_search_results.data.preview
    @page = search_results.support
  end

  private

  def search
    @search ||= Search.new(search_params)
  end

  def search_results
    @search_results ||= SearchService.call(search: search, relation: search_relation)
  end

  def freelex_search_results
    @freelex_search_results ||= FreelexSearchService.call(search: clone_search, relation: freelex_search_relation)
  end

  def search_relation
    policy_scope(Sign)
  end

  def freelex_search_relation
    policy_scope(FreelexSign)
  end

  def search_params
    { term: params.require(:term) }.merge(params.permit(:page, :sort))
  end

  def clone_search
    return search unless search.sort.to_s.downcase == "popular"

    clone = search.clone
    clone.sort = "alpha_asc"
    clone
  end
end
