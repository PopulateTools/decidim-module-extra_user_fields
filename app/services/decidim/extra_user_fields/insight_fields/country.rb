# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module InsightFields
      class Country < Base
        def initialize = super("country")

        def value_label(value)
          country = ISO3166::Country[value.to_s.strip.upcase]
          return value.to_s.humanize unless country

          country.translations[I18n.locale.to_s] || country.common_name || country.iso_short_name
        end
      end
    end
  end
end
