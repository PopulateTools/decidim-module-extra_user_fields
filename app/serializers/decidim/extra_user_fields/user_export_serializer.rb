# frozen_string_literal: true

module Decidim
  # This class serializes a User so can be exported to CSV
  module ExtraUserFields
    class UserExportSerializer < Decidim::DownloadYourDataSerializers::DownloadYourDataUserSerializer
      # Public: Exports a hash with the serialized data for the user including
      # extra user fields
      def serialize
        super.merge(blocking_data).merge(extra_user_fields).merge(processed_extra_user_fields)
      end

      def extra_user_fields
        [:gender, :country, :postal_code, :date_of_birth, :phone_number, :location, :underage, :statutory_representative_email].index_with do |key|
          extended_data[key]
        end
      end

      def blocking_data
        {
          blocked: resource.blocked,
          blocked_at: resource.blocked_at,
          blocking_justification: resource.blocking&.justification
        }
      end

      def extra_fields
        [
          :gender,
          :country,
          :postal_code,
          :date_of_birth,
          :phone_number,
          :location,
          :underage,
          :statutory_representative_email
          # Block ExtraUserFields AddExtraField

          # EndBlock
        ]
      end

      def extended_data
        @extended_data ||= resource.extended_data.symbolize_keys
      end

      def processed_extra_user_fields
        { interests: translated_interests(extended_data[:interests]) }
      end

      def translated_interests(keys)
        return if keys.blank?

        keys.filter_map { |key| I18n.t(key, scope: "decidim.extra_user_fields.interests") if key.present? }.join(", ")
      end
    end
  end
end
