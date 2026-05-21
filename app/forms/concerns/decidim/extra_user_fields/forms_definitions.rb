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
        attribute :age_range, String
        attribute :phone_number, String
        attribute :location, String
        attribute :underage, ActiveRecord::Type::Boolean
        attribute :statutory_representative_email, String
        attribute :select_fields, Hash, default: {}
        attribute :boolean_fields, Array, default: []
        attribute :text_fields, Hash, default: {}

        validates :country, presence: true, if: :country_required?
        validates :postal_code, presence: true, if: :postal_code_required?
        validates :date_of_birth, presence: true, if: :date_of_birth_required?
        validates :gender, presence: true, if: :gender_required?
        validates :gender, inclusion: { in: Decidim::ExtraUserFields.genders.map(&:to_s) }, allow_blank: true, if: :gender?
        validates :age_range, presence: true, if: :age_range_required?
        validates :age_range, inclusion: { in: Decidim::ExtraUserFields.age_ranges.map(&:to_s) }, allow_blank: true, if: :age_range?
        validates :phone_number, presence: true, if: :phone_number_required?
        validates(
          :phone_number,
          format: { with: ->(form) { Regexp.new(form.current_organization.extra_user_field_configuration(:phone_number)["pattern"]) } },
          if: :phone_number_format?
        )

        validates :location, presence: true, if: :location_required?
        validates :underage, presence: true, if: :underage?
        validates :statutory_representative_email,
                  presence: true,
                  "valid_email_2/email": { disposable: true },
                  if: :underage_accepted?
        validate :birth_date_under_limit
        validate :select_fields_configured
        validate :required_collection_fields
      end

      def map_model(model)
        extended_data = model.extended_data.with_indifferent_access

        self.country = extended_data[:country]
        self.postal_code = extended_data[:postal_code]
        self.date_of_birth = Date.parse(extended_data[:date_of_birth]) if extended_data[:date_of_birth].present?
        self.gender = extended_data[:gender]
        self.age_range = extended_data[:age_range]
        self.phone_number = extended_data[:phone_number]
        self.location = extended_data[:location]
        self.underage = extended_data[:underage]
        self.select_fields = extended_data[:select_fields] || {}
        self.boolean_fields = extended_data[:boolean_fields] || []
        self.text_fields = extended_data[:text_fields] || {}
        self.statutory_representative_email = extended_data[:statutory_representative_email]
      end

      # Virtual readers for individual custom collection fields.
      # These let the form builder access per-field values and errors
      # so it can apply is-invalid-label / is-invalid-input automatically.
      Decidim::ExtraUserFields.select_fields.each_key do |field_name|
        define_method(:"select_fields_#{field_name}") do
          (select_fields || {})[field_name.to_s] || (select_fields || {})[field_name.to_sym]
        end
      end

      Decidim::ExtraUserFields.text_fields.each do |field_name|
        define_method(:"text_fields_#{field_name}") do
          (text_fields || {})[field_name.to_s] || (text_fields || {})[field_name.to_sym]
        end
      end

      Decidim::ExtraUserFields::PROFILE_FIELDS.map(&:to_sym).each do |field|
        define_method(:"#{field}?") { extra_user_fields_enabled && current_organization.activated_extra_field?(field) }
        define_method(:"#{field}_required?") { extra_user_fields_enabled && current_organization.required_extra_field?(field) }
      end

      private

      def phone_number_format?
        return false unless phone_number?

        current_organization.extra_user_field_configuration(:phone_number)["pattern"].present?
      end

      def underage?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:underage)
      end

      def select_fields?
        extra_user_fields_enabled && current_organization.activated_extra_field?(:select_fields)
      end

      def underage_accepted?
        underage? && underage == "1"
      end

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
        current_organization.extra_user_fields.dig("underage", "limit")
      end

      def select_fields_configured
        return unless select_fields?

        select_fields.each do |field, value|
          next unless current_organization.extra_user_field_configuration(:select_fields).include?(field.to_s)

          conf = Decidim::ExtraUserFields.select_fields.with_indifferent_access[field]
          next unless conf.is_a?(Hash)
          next if conf.with_indifferent_access.has_key?(value)

          label = I18n.t("decidim.extra_user_fields.select_fields.#{field}.label", default: field.to_s.humanize)
          errors.add(:base, I18n.t("decidim.extra_user_fields.errors.select_fields", field: label))
        end
      end

      def required_collection_fields
        return unless extra_user_fields_enabled

        [:select_fields, :text_fields].each do |collection|
          next unless current_organization.activated_extra_field?(collection)

          active = current_organization.extra_user_field_configuration(collection)
          next unless active.is_a?(Hash)

          active.each do |field_name, _|
            next unless current_organization.collection_field_required?(collection, field_name)
            next if send(collection)[field_name.to_s].present? || send(collection)[field_name.to_sym].present?

            errors.add(:"#{collection}_#{field_name}", :blank)
          end
        end
      end
    end
  end
end
