# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Extra user fields definitions for forms
    module FormsDefinitions
      extend ActiveSupport::Concern

      included do
        include ::Decidim::ExtraUserFields::ApplicationHelper

        attribute :country, String
        attribute :postal_code, String
        attribute :date_of_birth, Decidim::Attributes::LocalizedDate
        attribute :gender, String

        validates :country, presence: true
        validates :postal_code, presence: true
        validates :date_of_birth, presence: true
        validates :gender, presence: true
      end

      def map_model(model)
        extended_data = model.extended_data.with_indifferent_access

        self.country = extended_data[:country]
        self.postal_code = extended_data[:postal_code]
        self.date_of_birth = Date.parse(extended_data[:date_of_birth]) if extended_data[:date_of_birth].present?
        self.gender = extended_data[:gender]
      end
    end
  end
end
