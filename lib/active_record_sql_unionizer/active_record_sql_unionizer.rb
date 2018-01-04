require "active_record"

module ActiveRecordSqlUnionizer
  extend ActiveSupport::Concern

  module ClassMethods
    def unionize(*queries)
      table_klass = self
      while table_klass.superclass != ActiveRecord::Base
        table_klass = table_klass.superclass
      end
      table_name = table_klass.to_s.underscore.downcase.pluralize

      sql_queries = queries.map do |query|
        query_string = query.is_a?(String) ? query : query.to_sql
        "(#{query_string})"
      end

      union_string = "(#{sql_queries.join(" UNION ")}) AS #{table_name}"

      sql = self.connection.unprepared_statement { union_string }
      self.from(sql)
    end
  end
end
