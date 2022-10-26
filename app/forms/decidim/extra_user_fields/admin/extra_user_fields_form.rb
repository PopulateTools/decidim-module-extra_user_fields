# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExtraUserFieldsForm < Decidim::Form
        include TranslatableAttributes

        attribute :enabled, Virtus::Attribute::Boolean

        def map_model(model)
          self.enabled = model.extra_user_fields["enabled"]
        end
      end
    end
  end
end
