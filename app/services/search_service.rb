# frozen_string_literal: true

class SearchService < ApplicationService
  attr_reader :search, :results

  def initialize(params)
    @search = params[:search]
    @results = ApplicationService.new_results
  end

  def process
    results.data = build_results
    results
  end

  private

  def build_results
    %w[FreelexSign Sign].inject([]) do |arr, name|
      arr << name.constantize
                 .select(:id, :english, :maori)
                 .where(["LOWER(english) LIKE ?", "%#{search.word.strip.downcase}%"])
                 .map(&:serializable_hash)
    end
  end
end
