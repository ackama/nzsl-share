# frozen_string_literal: true

class TopicSignService
  attr_reader :search, :results

  def initialize(search:, relation:)
    @search = search
    @relation = relation
    @results = SearchResults.new
  end

  def process
    results.data = build_results
    results.support = search.page_with_total
    results
  end

  private

  def build_results
    result_ids = parse_results(@relation.signs)
    result_relation = Sign.where(Sign.primary_key => result_ids)
    search.total = result_relation.count
    fetch_results(result_relation, result_ids)
  end

  def fetch_results(result_relation, result_ids)
    # binding.pry
    result_relation
      .limit(search.page[:limit])
      .order(Arel.sql("array_position(array[#{result_ids.join(",")}]::integer[],
                       \"#{Sign.table_name}\".\"#{Sign.primary_key}\")"))
  end

  def parse_results(results)
    results.pluck :id
  end
end
