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
              when ActiveRecord::Relation
                query.to_sql
              else
                raise(UnionizerError.new(type: :unknown_arg_type))
            end

        "(#{query_string})"
      end

      union_string = unionizer_helper.construct_final_query_string(sql_queries, table_name)

      sql = self.connection.unprepared_statement {union_string}
      self.from(sql)
    end
  end


  private

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
    def handle_symbol_arg(klass, method_name)
      if klass.respond_to?(method_name)
        klass.send(method_name).to_sql
      else
        raise(UnionizerError.new(type: :bad_method, class: klass.to_s, method_name: method_name))
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
    def initialize(options)
      if options[:type] == :unknown_arg_type
        msg = "ActiveRecordSqlUnionizer received an arguement that was not a SQL string, ActiveRecord::Relation, or scoping method name"
      elsif options[:type] == :bad_method
        msg = "ActiveRecordSqlUnionizer expected #{options[:class]} to respond to #{options[:method_name]}, but it does not"
      end
      super(msg)
    end
  end
end
