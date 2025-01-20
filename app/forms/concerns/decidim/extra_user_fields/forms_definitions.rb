# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Extra user fields definitions for forms
    module FormsDefinitions
      extend ActiveSupport::Concern

      included do
        include ::Decidim::ExtraUserFields::ApplicationHelper

        # Block ExtraUserFields Attributes

        attribute :country, String
        attribute :postal_code, String
        attribute :date_of_birth, Decidim::Attributes::LocalizedDate
        attribute :gender, String
        attribute :phone_number, String
        attribute :location, String
        attribute :underage, ActiveRecord::Type::Boolean
        attribute :statutory_representative_email, String

        # EndBlock

        # Block ExtraUserFields Validations

        validates :country, presence: true, if: :country?
        validates :postal_code, presence: true, if: :postal_code?
        validates :date_of_birth, presence: true, if: :date_of_birth?
        validates :gender, presence: true, inclusion: { in: Decidim::ExtraUserFields::Engine::DEFAULT_GENDER_OPTIONS.map(&:to_s) }, if: :gender?
        validates :phone_number, presence: true, if: :phone_number?
        validates(
          :phone_number,
          format: { with: ->(form) { Regexp.new(form.current_organization.extra_user_field_configuration(:phone_number)["pattern"]) } },
          if: :phone_number_format?
        )

        validates :location, presence: true, if: :location?
        validates :underage, presence: true, if: :underage?
        validates :statutory_representative_email,
                  presence: true,
                  "valid_email_2/email": { disposable: true },
                  if: :underage_accepted?
        validate :birth_date_under_limit

        # EndBlock
      end

      def map_model(model)
        extended_data = model.extended_data.with_indifferent_access

        self.country = extended_data[:country]
        self.postal_code = extended_data[:postal_code]
        self.date_of_birth = Date.parse(extended_data[:date_of_birth]) if extended_data[:date_of_birth].present?
        self.gender = extended_data[:gender]
        self.phone_number = extended_data[:phone_number]
        self.location = extended_data[:location]
        self.underage = extended_data[:underage]
        self.statutory_representative_email = extended_data[:statutory_representative_email]

        # Block ExtraUserFields MapModel

        # EndBlock
      end

      private

      # Block ExtraUserFields EnableFieldMethod
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

      def phone_number?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:phone_number)
      end

      def phone_number_format?
        return unless phone_number?

        current_organization.extra_user_field_configuration(:phone_number)["pattern"].present?
      end

      def location?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:location)
      end

      def underage?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:underage)
      end

      def underage_accepted?
        underage? && underage == "1"
      end

      # EndBlock

      def extra_user_fields_enabled
        @extra_user_fields_enabled ||= current_organization.extra_user_fields_enabled?
      end

      # Method to check if birth date is under the limit
      def birth_date_under_limit
        return unless date_of_birth? && underage?

        return if date_of_birth.blank? || underage.blank? || underage_limit.blank?

        age = calculate_age(date_of_birth)

        validate_age(age)
      end

      def calculate_age(date_of_birth)
        Time.zone.today.year - date_of_birth.year - (Time.zone.today.yday < date_of_birth.yday ? 1 : 0)
      end

      def validate_age(age)
        errors.add(:date_of_birth, :underage) unless underage_within_limit?(age)
        underage_within_limit?(age)
      end

      def underage_within_limit?(age)
        (date_of_birth.present? && age < underage_limit && underage_accepted?) || (age > underage_limit && !underage_accepted?)
      end

      def underage_limit
        current_organization.extra_user_fields["underage_limit"]
      end
    end
  end
end
