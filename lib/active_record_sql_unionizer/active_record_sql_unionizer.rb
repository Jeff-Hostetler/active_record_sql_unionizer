require "active_record"

module ActiveRecordSqlUnionizer
  extend ActiveSupport::Concern

  module ClassMethods
    #passed in objects can be valid SQL strings, ActiveRecord::Relation, and class methods
    #as symbols that return an ActiveRecord::Relation.
    # @param [Splat] queries
    #
    # @return [ActiveRecord::Relation]
    def unionize(*queries)
      unionizer_helper = UnionizerHelper.new

      table_name = unionizer_helper.get_table_name(self)

      sql_queries = queries.map do |query|
        query_string =
            case query
              when String
                query
              when Symbol
                unionizer_helper.handle_symbol_arg(self, query)
              else
                query.to_sql
            end

        "(#{query_string})"
      end

      union_string = unionizer_helper.construct_final_query_string(sql_queries, table_name)

      sql = self.connection.unprepared_statement {union_string}
      self.from(sql)
    end
  end

  class UnionizerHelper
    #for 'private' methods/ readability

    # @param [Object] klass
    #
    # @return [String]
    def get_table_name(klass)
      table_klass = klass
      while table_klass.superclass != ActiveRecord::Base
        table_klass = table_klass.superclass
      end
      table_klass.to_s.underscore.downcase.pluralize
    end

    # @param [Symbol] arg
    #
    # @return [String, UnionizerError]
    def handle_symbol_arg(klass, arg)
      if klass.respond_to?(arg)
        klass.send(arg).to_sql
      else
        raise(UnionizerError.new(klass.to_s, arg))
      end
    end

    # @param [Array<String>] queries
    # @param [String] table_name
    #
    # @return [String]
    def construct_final_query_string(queries, table_name)
      "(#{queries.join(" UNION ")}) AS #{table_name}"
    end
  end

  class UnionizerError < StandardError
    # @param [String] klass_name
    # @param [Symbol] method_name
    #
    # @return [UnionizerError]
    def initialize(klass_name, method_name)
      msg = "ActiveRecordSqlUnionizer expected #{klass_name} to respond to #{method_name}, but it does not"
      super(msg)
    end
  end
end
