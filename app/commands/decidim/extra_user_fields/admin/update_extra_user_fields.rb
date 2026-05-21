# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # A command with all the business logic when updating organization's extra user fields in signup form
      class UpdateExtraUserFields < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_extra_user_fields!

          broadcast(:ok)
        end

        private

        attr_reader :form

        def update_extra_user_fields!
          Decidim.traceability.update!(
            form.current_organization,
            form.current_user,
            extra_user_fields:
          )
        end

        def extra_user_fields
          {
            "enabled" => form.enabled.presence || false,
            **standard_fields,
            **phone_number_fields,
            "underage" => underage_fields,
            "select_fields" => normalize_select_fields,
            "boolean_fields" => normalize_boolean_fields,
            "text_fields" => normalize_text_fields
          }
        end

        def standard_fields
          (Decidim::ExtraUserFields::PROFILE_FIELDS - %w(phone_number)).index_with do |field|
            enabled = form.public_send(:"#{field}_enabled") == true
            {
              "enabled" => enabled,
              "required" => enabled && form.public_send(:"#{field}_required") == true
            }
          end
        end

        def phone_number_fields
          enabled = form.phone_number_enabled == true
          {
            "phone_number" => {
              "enabled" => enabled,
              "required" => enabled && form.phone_number_required == true,
              "pattern" => form.phone_number_pattern.presence,
              "placeholder" => form.phone_number_placeholder.presence
            }.compact
          }
        end

        def underage_fields
          enabled = form.underage_enabled == true
          {
            "enabled" => enabled,
            "required" => enabled && form.underage_required == true,
            "limit" => form.underage_limit || Decidim::ExtraUserFields.underage_limit
          }
        end

        def normalize_select_fields
          normalize_collection_fields(:select_fields)
        end

        def normalize_boolean_fields
          normalize_collection_fields(:boolean_fields, allow_required: false)
        end

        def normalize_text_fields
          normalize_collection_fields(:text_fields)
        end

        def normalize_collection_fields(name, allow_required: true)
          data = form.public_send(name)
          return {} unless data.is_a?(Hash)

          data.transform_values do |field_data|
            next({ "enabled" => false, "required" => false }) if field_data.blank? || !field_data.is_a?(Hash)

            enabled = field_data["enabled"] == "true"
            required = allow_required && field_data["required"] == "true"

            {
              "enabled" => enabled,
              "required" => enabled && required
            }
          end
        end
      end
    end
  end
end
