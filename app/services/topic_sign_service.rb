# frozen_string_literal: true

require "./lib/sql/status"

class TopicSignService
  attr_reader :search, :results

  def initialize(search:, relation:, topic:)
    @search = search
    @relation = relation
    @topic = topic
    @results = SearchResults.new
  end

  def process
    results.data = build_results
    results.support = search.page_with_total
    results
  end

  private

  def build_results
    sql_arr = [SQL::Status.all_signs(search.order_clause)]
    result_ids = parse_results(exec_query(sql_arr))

    result_relation = choose_topic.where(@relation.primary_key => result_ids)

    # use length, so we don't try and count in SQL, because when there is a group by in the query such as in the
    # uncategorised scope the count returns a hash of the count of each grouped result
    # but we just want to know how many resutls there are in total
    search.total = result_relation.length
    fetch_results(result_relation, result_ids)
  end

  def choose_topic
    if @topic.id.nil?
      @relation.uncategorised
    else
      @relation.joins(:sign_topics)
               .where(sign_topics: { topic_id: [@topic.id] })
    end
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
