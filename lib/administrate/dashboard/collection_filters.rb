require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"

module Administrate
  module Dashboard
    class CollectionFilters
      def initialize(dashboard_class)
        @dashboard_class = dashboard_class
      end

      def filters
        if @dashboard_class.const_defined?(:COLLECTION_FILTERS)
          @dashboard_class.const_get(:COLLECTION_FILTERS).stringify_keys
        else
          {}
        end
      end

      def filter_keys
        filters.stringify_keys
      end
    end
  end
end
