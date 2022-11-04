# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExtraUserFieldsForm < Decidim::Form
        include TranslatableAttributes

        attribute :enabled, Virtus::Attribute::Boolean
        attribute :country, Virtus::Attribute::Boolean
        attribute :postal_code, Virtus::Attribute::Boolean
        attribute :date_of_birth, Virtus::Attribute::Boolean
        attribute :gender, Virtus::Attribute::Boolean
        # Block ExtraUserFields Attributes

        # EndBlock

        def map_model(model)
          self.enabled = model.extra_user_fields["enabled"]
          self.country = model.extra_user_fields.dig("country", "enabled")
          self.postal_code = model.extra_user_fields.dig("postal_code", "enabled")
          self.date_of_birth = model.extra_user_fields.dig("date_of_birth", "enabled")
          self.gender = model.extra_user_fields.dig("gender", "enabled")
          # Block ExtraUserFields MapModel

          # EndBlock
        end
      end
    end
  end
end
