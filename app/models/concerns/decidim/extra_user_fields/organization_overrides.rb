# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module OrganizationOverrides
      extend ActiveSupport::Concern

      # If true display registration field in signup form
      def extra_user_fields_enabled?
        extra_user_fields["enabled"].present? && at_least_one_extra_field?
      end

      def has_required_extra_user_fields?
        extra_user_fields_enabled? && any_required_field?
      end

      def required_extra_field?(field)
        field_data = extra_user_fields[field.to_s]
        return false unless field_data.is_a?(Hash)

        field_data["required"] == true
      end

      def extra_user_fields_complete?(user)
        extended_data = user.extended_data

        profile_field_names.each do |field|
          next unless required_extra_field?(field)

          return false if extended_data[field].blank?
        end

        check_collection_fields_complete?(extended_data, :select_fields) &&
          check_collection_fields_complete?(extended_data, :text_fields)
      end

      def at_least_one_extra_field?
        (profile_field_names + %w(underage select_fields boolean_fields text_fields)).any? do |field|
          activated_extra_field?(field)
        end
      end

      COLLECTION_FIELDS = %w(select_fields boolean_fields text_fields).freeze

      def activated_extra_field?(field)
        value = extra_user_fields[field.to_s]
        return false if value.blank?
        return false unless value.is_a?(Hash)

        if COLLECTION_FIELDS.include?(field.to_s)
          value.any? { |_, v| v.is_a?(Hash) && v["enabled"] == true }
        else
          value["enabled"] == true
        end
      end

      # Check if a field within a collection (select_fields, text_fields, boolean_fields) is required.
      def collection_field_required?(collection, field)
        fields = extra_user_fields[collection.to_s]
        return false unless fields.is_a?(Hash)

        field_data = fields[field.to_s]
        return false unless field_data.is_a?(Hash)

        field_data["required"] == true
      end

      def age_limit
        extra_user_fields.dig("underage", "limit").to_i
      end

      def extra_user_field_configuration(field)
        return {} unless activated_extra_field?(field)

        value = extra_user_fields[field.to_s]

        # For collection fields (select_fields, text_fields, boolean_fields), return the hash of all fields
        # For other fields, return the configuration (excluding enabled/required for simple access)
        if %w(select_fields text_fields boolean_fields).include?(field.to_s)
          value.is_a?(Hash) ? value : {}
        else
          value.is_a?(Hash) ? value.except("enabled", "required") : {}
        end
      end

      private

      def profile_field_names
        Decidim::ExtraUserFields::PROFILE_FIELDS
      end

      def any_required_field?
        profile_field_names.any? { |field| required_extra_field?(field) } ||
          %w(select_fields text_fields).any? do |collection|
            fields = extra_user_fields[collection]
            fields.is_a?(Hash) && fields.keys.any? { |name| collection_field_required?(collection, name) }
          end
      end

      def check_collection_fields_complete?(extended_data, collection_name)
        active_fields = extra_user_fields.fetch(collection_name.to_s, {})
        return true if active_fields.blank? || !active_fields.is_a?(Hash)

        user_data = extended_data.fetch(collection_name.to_s, {})
        active_fields.each do |field_name, _|
          next unless collection_field_required?(collection_name, field_name)

          return false if user_data[field_name.to_s].blank?
        end
        true
      end
    end
  end
end
