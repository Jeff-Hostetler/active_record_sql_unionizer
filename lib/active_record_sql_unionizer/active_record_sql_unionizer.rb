require "active_record"

module ActiveRecordSqlUnionizer
  extend ActiveSupport::Concern
  module ClassMethods
    # passed in objects can be valid SQL strings, ActiveRecord::Relation,
    # and class methods as symbols that return an ActiveRecord::Relation or SQL strings.
    #
    # @param [Splat] queries
    #
    # @return [ActiveRecord::Relation]
    def unionize(*queries)
      unionizer_helper = UnionizerHelper.new

      sql_strings = queries.map do |query|
        "(#{unionizer_helper.query_to_sql_string(self, query, :unknown_arg_type)})"
      end

      table_name = unionizer_helper.get_table_name(self)
      final_query = self.connection.unprepared_statement { "(#{sql_strings.join(" UNION ")}) AS #{table_name}" }
      self.from(final_query)
    end
  end


  private

  class UnionizerHelper
    # for 'private' methods/ readability

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

    # @param [Object] klass
    # @param [Symbol] method_name
    #
    # @return [String, UnionizerError]
    def handle_symbol_arg(klass, method_name)
      if klass.respond_to?(method_name)
        query_to_sql_string(klass, klass.send(method_name), :bad_method, method_name)
      else
        raise(UnionizerError.new(type: :undefined_method, class_name: klass.to_s, method_name: method_name))
      end
    end

    # @param [ActiveRecord::Relation, String, Symbol] query
    #
    # @return [String, UnionizerError]
    def query_to_sql_string(klass, query, error_type, override_method_name=nil)
      case query
        when String
          query
        when Symbol
          self.handle_symbol_arg(klass, query)
        when ActiveRecord::Relation
          query.to_sql
        else
          raise(UnionizerError.new(type: error_type, class_name: klass.to_s, method_name: (override_method_name || query)))
      end
    end
  end

  class UnionizerError < StandardError
    # @param [Hash] options
    #
    # @return [UnionizerError]
    def initialize(options)
      error_type = options[:type]
      class_name = options[:class_name]
      method_name = options[:method_name]

      msg =
        case error_type
          when :unknown_arg_type
            "ActiveRecordSqlUnionizer received an arguement that was not a SQL string, ActiveRecord::Relation, or scoping method name"
          when :undefined_method
            "ActiveRecordSqlUnionizer expected #{class_name} to respond to #{method_name}, but it does not"
          when :bad_method
            "ActiveRecordSqlUnionizer expected #{class_name}.#{method_name} to return an ActiveRecord::Relation or SQL string, but it does not"
        end

      super(msg)
    end
  end
end
