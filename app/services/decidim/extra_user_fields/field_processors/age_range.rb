# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module FieldProcessors
      # Computes age from date_of_birth and matches it to an insight_age_span.
      # Ignores the stored age_range field; users without date_of_birth get nil.
      class AgeRange
        RANGE_PATTERNS = {
          /\Aup_to_(?<max>\d+)\z/ => ->(m) { ..m[:max].to_i },
          /\A(?<min>\d+)_to_(?<max>\d+)\z/ => ->(m) { m[:min].to_i..m[:max].to_i },
          /\A(?<min>\d+)_or_more\z/ => ->(m) { m[:min].to_i.. }
        }.freeze

        def self.call(extended_data)
          return if extended_data["date_of_birth"].blank?

          compute_age(extended_data["date_of_birth"])&.then { |age| match_range(age) }
        end

        def self.compute_age(date_string)
          birth = Date.parse(date_string.to_s)
          today = Date.current
          age = today.year - birth.year
          age -= 1 if today.month < birth.month || (today.month == birth.month && today.day < birth.day)
          age if age >= 0
        rescue Date::Error
          nil
        end

        def self.match_range(age)
          Decidim::ExtraUserFields.insight_age_spans.find { |name| parse_range(name)&.cover?(age) }
        end

        def self.parse_range(name)
          RANGE_PATTERNS.each do |pattern, builder|
            match = name.match(pattern)
            return builder.call(match) if match
          end
          nil
        end

        private_class_method :compute_age, :match_range, :parse_range
      end
    end
  end
end
