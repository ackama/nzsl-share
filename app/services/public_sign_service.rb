# frozen_string_literal: true

require "./lib/sql/status"

class PublicSignService < ApplicationService
  attr_reader :search, :results

  def initialize(search:, relation:)
    super
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
    sql_arr = [SQL::Status.public_signs(search.order_clause)]
    result_ids = parse_results(exec_query(sql_arr))
    result_relation = @relation.where(@relation.primary_key => result_ids)
    search.total = result_relation.count
    fetch_results(result_relation, result_ids)
  end

  def fetch_results(result_relation, result_ids)
    result_relation
      .limit(search.page[:limit])
      .order(Arel.sql("array_position(array[#{result_ids.join(",")}]::integer[],
                       \"#{@relation.table_name}\".\"#{@relation.primary_key}\")"))
  end

  def parse_results(results)
    results.field_values(@relation.primary_key)
  end

  def exec_query(sql_arr)
    ApplicationRecord.connection.execute(ApplicationRecord.send(:sanitize_sql_array, sql_arr))
  end
end
