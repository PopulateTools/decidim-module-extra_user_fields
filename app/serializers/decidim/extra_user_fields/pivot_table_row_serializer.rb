# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # This class serializes a pivot table row so it can be exported to CSV, JSON or other formats.
    class PivotTableRowSerializer < Decidim::Exporters::Serializer
      # Public: Exports a hash with the serialized data for this row.
      def serialize
        resource
      end
    end
  end
end
