module Administrate
  class Search
    private

    def query_table_name(attr)
      if association_search?(attr)
        table_name = begin
                       attribute_types[attr]
                         .options.fetch(:class_name).constantize.table_name
                     rescue StandardError
                       attr.to_s.pluralize
                     end

        ActiveRecord::Base.connection.quote_table_name(table_name)
      else
        ActiveRecord::Base.connection
                          .quote_table_name(@scoped_resource.table_name)
      end
    end

    def tables_to_join
      attribute_types.keys.map do |attribute|
        next unless attribute_types[attribute].searchable? && association_search?(attribute)

        attribute_types[attribute].options.fetch(:source, attribute)
      end
    end
  end
end
