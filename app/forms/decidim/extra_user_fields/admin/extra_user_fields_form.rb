# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExtraUserFieldsForm < Decidim::Form
        include TranslatableAttributes

        attribute :extra_user_fields_enabled, Virtus::Attribute::Boolean
      end
    end
  end
end
