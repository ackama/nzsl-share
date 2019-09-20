# frozen_string_literal: true

class SearchService < ApplicationService
  attr_reader :results

  def initialize(params)
    @word = params[:word]
    @results = ApplicationService::Results.new
    execute
  end

  private

  def execute
    results.data = %w[FreelexSign Sign].inject([]) do |arr, name|
      arr << name.constantize
                 .select(:id, :english, :maori)
                 .where(["LOWER(english) LIKE ?", "%#{@word.strip.downcase}%"])
                 .map(&:serializable_hash)
    end
    results.data.flatten!
  end
end
