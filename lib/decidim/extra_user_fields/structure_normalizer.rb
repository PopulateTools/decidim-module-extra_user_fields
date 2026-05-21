# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    class StructureNormalizer
      def normalize_all
        Decidim::Organization.find_each do |organization|
          next if organization.extra_user_fields.blank?

          normalized = normalize_structure(organization.extra_user_fields)
          organization.update_column(:extra_user_fields, normalized) # rubocop:disable Rails/SkipsModelValidations
        end
      end

      private

      def normalize_structure(fields)
        {
          "enabled" => fields["enabled"].presence || false
        }.tap do |result|
          # Normalize standard profile fields
          normalize_profile_fields(fields, result)

          # Normalize phone_number (keep extra properties)
          normalize_phone_number(fields, result)

          # Normalize underage (merge underage_limit into it)
          normalize_underage(fields, result)

          # Normalize collection fields
          normalize_select_fields(fields, result)
          normalize_boolean_fields(fields, result)
          normalize_text_fields(fields, result)
        end
      end

      def normalize_profile_fields(fields, result)
        %w(country postal_code date_of_birth gender age_range location).each do |field|
          next unless fields.has_key?(field)

          field_value = fields[field]
          if already_normalized?(field_value)
            result[field] = field_value
          else
            state = if field_value.is_a?(Hash) && field_value.has_key?("enabled")
                      field_value["enabled"]
                    else
                      field_value
                    end
            result[field] = convert_state_to_booleans(state)
          end
        end
      end

      def normalize_phone_number(fields, result)
        return unless fields.has_key?("phone_number")

        phone_data = fields["phone_number"]
        if phone_data.is_a?(Hash)
          if already_normalized?(phone_data)
            result["phone_number"] = phone_data
          else
            state = phone_data["enabled"]
            result["phone_number"] = convert_state_to_booleans(state).merge(
              "pattern" => phone_data["pattern"],
              "placeholder" => phone_data["placeholder"]
            ).compact
          end
        else
          result["phone_number"] = convert_state_to_booleans(phone_data)
        end
      end

      def normalize_underage(fields, result)
        underage_data = fields["underage"]
        underage_limit = fields["underage_limit"]

        if underage_data.is_a?(Hash)
          # New format or partial migration
          enabled = underage_data["enabled"]
          limit = underage_data["limit"] || underage_limit || 18
          required = underage_data["required"] == true
          result["underage"] = {
            "enabled" => enabled == true || enabled == "true",
            "required" => required,
            "limit" => limit
          }
        elsif underage_data.present?
          # Legacy boolean
          result["underage"] = {
            "enabled" => underage_data == true || underage_data == "true",
            "required" => false,
            "limit" => underage_limit || 18
          }
        else
          result["underage"] = {
            "enabled" => false,
            "required" => false,
            "limit" => underage_limit || 18
          }
        end
      end

      def normalize_select_fields(fields, result)
        select_data = fields["select_fields"]
        return if select_data.blank?

        result["select_fields"] = normalize_collection(select_data)
      end

      def normalize_boolean_fields(fields, result)
        boolean_data = fields["boolean_fields"]
        return if boolean_data.blank?

        result["boolean_fields"] = normalize_collection(boolean_data)
      end

      def normalize_text_fields(fields, result)
        text_data = fields["text_fields"]
        return if text_data.blank?

        result["text_fields"] = normalize_collection(text_data)
      end

      def normalize_collection(data)
        if data.is_a?(Array)
          data.index_with { |_| { "enabled" => true, "required" => false } }
        elsif data.is_a?(Hash)
          data.transform_values do |value|
            if value.is_a?(Hash) && value.has_key?("enabled")
              value
            else
              convert_state_to_booleans(value)
            end
          end
        else
          {}
        end
      end

      def already_normalized?(value)
        value.is_a?(Hash) &&
          [true, false].include?(value["enabled"]) &&
          [true, false].include?(value["required"])
      end

      def convert_state_to_booleans(state)
        case state
        when "optional", true
          { "enabled" => true, "required" => false }
        when "required"
          { "enabled" => true, "required" => true }
        else # "disabled", false, nil, or unknown
          { "enabled" => false, "required" => false }
        end
      end
    end
  end
end
