# frozen_string_literal: true

module Decidim
  # This class serializes a User so can be exported to CSV
  module ExtraUserFields
    class UserExportSerializer < Decidim::DataPortabilitySerializers::DataPortabilityUserSerializer
      # Public: Exports a hash with the serialized data for the user including
      # extra user fields
      def serialize
        super.merge(extra_user_fields)
      end

      def extra_user_fields
        extended_data = resource.extended_data.symbolize_keys

        extra_fields.index_with do |key|
          extended_data[key]
        end
      end

      # rubocop:disable Style/TrailingCommaInArrayLiteral
      def extra_fields
        [
          :gender,
          :country,
          :postal_code,
          :date_of_birth,
          # Block ExtraUserFields AddExtraField

          # EndBlock
        ]
      end
      # rubocop:enable Style/TrailingCommaInArrayLiteral
    end
  end
end
