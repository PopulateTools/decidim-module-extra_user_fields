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

        # Block ExtraUserFields Attributes

        # EndBlock

        validates :country, presence: true, if: :country?
        validates :postal_code, presence: true, if: :postal_code?
        validates :date_of_birth, presence: true, if: :date_of_birth?
        validates :gender, presence: true, inclusion: { in: Decidim::ExtraUserFields::Engine::DEFAULT_GENDER_OPTIONS.map(&:to_s) }, if: :gender?

        # Block ExtraUserFields Validations

        # EndBlock
      end

      def map_model(model)
        extended_data = model.extended_data.with_indifferent_access

        self.country = extended_data[:country]
        self.postal_code = extended_data[:postal_code]
        self.date_of_birth = Date.parse(extended_data[:date_of_birth]) if extended_data[:date_of_birth].present?
        self.gender = extended_data[:gender]

        # Block ExtraUserFields MapModel

        # EndBlock
      end

      private

      def country?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:country)
      end

      def date_of_birth?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:date_of_birth)
      end

      def gender?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:gender)
      end

      def postal_code?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:postal_code)
      end

      # Block ExtraUserFields EnableFieldMethod

      # EndBlock

      def extra_user_fields_enabled
        @extra_user_fields_enabled ||= current_organization.extra_user_fields_enabled?
      end
    end
  end
end
