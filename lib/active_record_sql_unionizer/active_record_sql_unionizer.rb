require "active_record"

module ActiveRecordSqlUnionizer
  extend ActiveSupport::Concern

  module ClassMethods
    def unionize(*queries)
      union_string = queries.map do |query|
        query_string = query.is_a?(String) ? query : query.to_sql
        "(#{query_string})"
      end.join(" UNION ")
      union_string = "(#{union_string}) AS #{self.to_s.underscore.downcase.pluralize}"

      sql = self.connection.unprepared_statement {union_string}
      self.from(sql)
    end
  end
end
