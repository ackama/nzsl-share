class PublicSignsController < ApplicationController
  def index
    @signs = search_results.data
    @page = search_results.support
  end

  private

  def search
    @search ||= Search.new(params.permit(:page, :sort))
  end

  def search_results
    @search_results ||= PublicSignService.new(search: search, relation: policy_scope(Sign)).process
  end
end
