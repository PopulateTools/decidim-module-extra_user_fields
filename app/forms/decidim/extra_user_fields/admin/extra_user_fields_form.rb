# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExtraUserFieldsForm < Decidim::Form
        include TranslatableAttributes

        attribute :enabled, Boolean

        # Profile fields - each field has enabled and required booleans
        Decidim::ExtraUserFields::PROFILE_FIELDS.each do |field|
          attribute :"#{field}_enabled", Boolean
          attribute :"#{field}_required", Boolean
        end

        # Underage is separate (not in PROFILE_FIELDS)
        attribute :underage_enabled, Boolean
        attribute :underage_required, Boolean
        attribute :underage_limit, Integer

        attribute :phone_number_pattern, String
        translatable_attribute :phone_number_placeholder, String

        # Collection fields - stored as hashes with field names as keys
        attribute :select_fields, Hash, default: {}
        attribute :boolean_fields, Hash, default: {}
        attribute :text_fields, Hash, default: {}

        def map_model(model)
          self.enabled = model.extra_user_fields["enabled"]

          Decidim::ExtraUserFields::PROFILE_FIELDS.each do |field|
            field_data = model.extra_user_fields[field]
            if field_data.is_a?(Hash)
              send(:"#{field}_enabled=", field_data["enabled"] == true)
              send(:"#{field}_required=", field_data["required"] == true)
            else
              # Default to disabled if field data is missing or nil
              send(:"#{field}_enabled=", false)
              send(:"#{field}_required=", false)
            end
          end

          # Load underage settings
          underage_data = model.extra_user_fields["underage"]
          if underage_data.is_a?(Hash)
            self.underage_enabled = underage_data["enabled"] == true
            self.underage_required = underage_data["required"] == true
            self.underage_limit = underage_data["limit"] || Decidim::ExtraUserFields.underage_limit
          else
            self.underage_enabled = false
            self.underage_required = false
            self.underage_limit = Decidim::ExtraUserFields.underage_limit
          end

          self.phone_number_pattern = model.extra_user_fields.dig("phone_number", "pattern")
          self.phone_number_placeholder = model.extra_user_fields.dig("phone_number", "placeholder")
          self.select_fields = normalize_collection_fields(model.extra_user_fields["select_fields"], Decidim::ExtraUserFields.select_fields.keys)
          self.boolean_fields = normalize_collection_fields(model.extra_user_fields["boolean_fields"], Decidim::ExtraUserFields.boolean_fields.map(&:to_s))
          self.text_fields = normalize_collection_fields(model.extra_user_fields["text_fields"], Decidim::ExtraUserFields.text_fields)
        end

        private

        def normalize_collection_fields(value, valid_keys)
          valid = valid_keys.map(&:to_s)
          defaults = valid.index_with { |_| { "enabled" => false, "required" => false } }

          return defaults unless value.is_a?(Hash)

          valid.each_with_object({}) do |k, result|
            v = value[k]
            result[k] = if v.is_a?(Hash)
                          v.merge("enabled" => v["enabled"] == true, "required" => v["enabled"] == true && v["required"] == true)
                        else
                          { "enabled" => false, "required" => false }
                        end
          end
        end
      end
    end
  end
end
