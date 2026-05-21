# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module InsightFields
      class Gender < Base
        def initialize = super("gender")

        def ordered_values
          Decidim::ExtraUserFields.genders - ["prefer_not_to_say"]
        end

        def value_label(value)
          I18n.t("decidim.extra_user_fields.genders.#{value}", default: value.to_s.humanize)
        end
      end
    end
  end
end
