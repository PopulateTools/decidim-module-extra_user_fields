# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module InsightFields
      class Base
        attr_reader :field_name

        def initialize(field_name)
          @field_name = field_name.to_s
        end

        def extract(extended_data)
          normalize(extended_data[field_name].presence)
        end

        def ordered_values
          nil
        end

        def value_label(value)
          I18n.t(
            "decidim.admin.extra_user_fields.insights.field_values.#{field_name}.#{value}",
            default: value.to_s.humanize
          )
        end

        private

        def normalize(value)
          value == "prefer_not_to_say" ? nil : value
        end
      end
    end
  end
end
