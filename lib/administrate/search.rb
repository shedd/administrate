require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"

module Administrate
  class Search
    class Query
      attr_reader :filters

      def blank?
        terms.blank? && filters.empty?
      end

      def initialize(original_query)
        @original_query = original_query
        @filters, @terms = parse_query(original_query)
      end

      def original
        @original_query
      end

      def terms
        @terms.join(" ")
      end

      def to_s
        original
      end

      private

      def filter?(word)
        word.match(/^\w+:$/)
      end

      def parse_query(query)
        filters = []
        terms = []
        query.to_s.split.each do |word|
          if filter?(word)
            filters << word.split(":").first
          else
            terms << word
          end
        end
        [filters, terms]
      end
    end

    def initialize(scoped_resource, dashboard_class, term)
      @dashboard_class = dashboard_class
      @scoped_resource = scoped_resource
      @query = Query.new(term)
    end

    def run
      if query.blank?
        @scoped_resource.all
      else
        results = search_results(@scoped_resource)
        results = filter_results(results)
        results
      end
    end

    private

    def apply_filter(filter, resources)
      return resources unless filter
      filter.call(resources)
    end

    def filter_results(resources)
      query.filters.each do |filter_name|
        filter = valid_filters[filter_name]
        resources = apply_filter(filter, resources)
      end
      resources
    end

    def query_template
      search_attributes.map do |attr|
        table_name = ActiveRecord::Base.connection.
          quote_table_name(@scoped_resource.table_name)
        attr_name = ActiveRecord::Base.connection.quote_column_name(attr)
        "lower(#{table_name}.#{attr_name}) LIKE ?"
      end.join(" OR ")
    end

    def query_values
      ["%#{term.mb_chars.downcase}%"] * search_attributes.count
    end

    def search_attributes
      attribute_types.keys.select do |attribute|
        attribute_types[attribute].searchable?
      end
    end

    def search_results(resources)
      resources.where(query_template, *query_values)
    end

    def valid_filters
      Dashboard::CollectionFilters.new(@dashboard_class).filter_keys
    end

    def attribute_types
      @dashboard_class::ATTRIBUTE_TYPES
    end

    def term
      query.terms
    end

    attr_reader :resolver, :query
  end
end
