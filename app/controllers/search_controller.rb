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
    @search_results ||= SearchService.new(search: search, relation: search_relation).process
  end

  def freelex_search_results
    @freelex_search_results ||= FreelexSearchService.new(search: freelex_search,
                                                         relation: freelex_search_relation).process
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

  def freelex_search
    return search unless search.sort.to_s.downcase == "popular"

    clone = search.clone
    clone.sort = "alpha_asc"
    clone
  end
end
