# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Resolves insight field names to their strategy objects.
    # Convention: "gender" -> InsightFields::Gender, "age_span" -> InsightFields::AgeSpan.
    # Falls back to Base for unknown fields (reads extended_data directly).
    module InsightFields
      def self.for(field_name)
        const_name = field_name.to_s.camelize
        return Base.new(field_name) unless const_defined?(const_name, false)

        const_get(const_name, false).new
      end
    end
  end
end
