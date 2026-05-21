# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module InsightFields
      class AgeSpan < Base
        def initialize = super("age_span")

        def extract(extended_data)
          normalize(FieldProcessors::AgeRange.call(extended_data))
        end

        def ordered_values
          Decidim::ExtraUserFields.insight_age_spans
        end

        def value_label(value)
          I18n.t("decidim.extra_user_fields.insight_age_spans.#{value}", default: value.to_s.humanize)
        end
      end
    end
  end
end
