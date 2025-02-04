# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExtraUserFieldsForm < Decidim::Form
        include TranslatableAttributes

        attribute :enabled, Boolean
        attribute :country, Boolean
        attribute :postal_code, Boolean
        attribute :date_of_birth, Boolean
        attribute :gender, Boolean
        attribute :phone_number, Boolean
        attribute :location, Boolean
        attribute :underage, Boolean
        attribute :underage_limit, Integer

        attribute :phone_number_pattern, String
        translatable_attribute :phone_number_placeholder, String
        # Block ExtraUserFields Attributes

        # EndBlock

        def map_model(model)
          self.enabled = model.extra_user_fields["enabled"]
          self.country = model.extra_user_fields.dig("country", "enabled")
          self.postal_code = model.extra_user_fields.dig("postal_code", "enabled")
          self.date_of_birth = model.extra_user_fields.dig("date_of_birth", "enabled")
          self.gender = model.extra_user_fields.dig("gender", "enabled")
          self.phone_number = model.extra_user_fields.dig("phone_number", "enabled")
          self.location = model.extra_user_fields.dig("location", "enabled")
          self.underage = model.extra_user_fields.dig("underage", "enabled")
          self.underage_limit = model.extra_user_fields.fetch("underage_limit", Decidim::ExtraUserFields::Engine::DEFAULT_UNDERAGE_LIMIT)
          self.phone_number_pattern = model.extra_user_fields.dig("phone_number", "pattern")
          self.phone_number_placeholder = model.extra_user_fields.dig("phone_number", "placeholder")
          # Block ExtraUserFields MapModel

          # EndBlock
        end
      end
    end
  end
end
