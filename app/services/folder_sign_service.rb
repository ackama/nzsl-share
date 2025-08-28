# frozen_string_literal: true

require "./lib/sql/status"

class FolderSignService
  def initialize(search:, relation:, folder:)
    @search = search
    @relation = relation
    @folder = folder
  end

  def process
    results = SearchResults.new
    results.data = build_results
    results.support = @search.page_with_total
    results
  end

  private

  def build_results
    sql_arr = [SQL::Status.all_signs(@search.order_clause)]
    result_ids = parse_results(exec_query(sql_arr))

    result_relation = @relation.joins(:folder_memberships)
                               .where(folder_memberships: { folder_id: [@folder.id] })
                               .where(@relation.primary_key => result_ids)
    @search.total = result_relation.count
    fetch_results(result_relation, result_ids)
  end

  def fetch_results(result_relation, result_ids)
    result_relation
      .limit(@search.page[:limit])
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
