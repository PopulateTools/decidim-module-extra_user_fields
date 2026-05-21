# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module UpdateAccountCommandsOverrides
      extend ActiveSupport::Concern

      private

      def update_personal_data
        current_user.locale = @form.locale
        current_user.name = @form.name
        current_user.nickname = @form.nickname
        current_user.email = @form.email
        current_user.personal_url = @form.personal_url
        current_user.about = @form.about
        current_user.extended_data = extended_data
      end

      def extended_data
        @extended_data ||= (current_user&.extended_data || {}).merge(
          country: @form.country,
          postal_code: @form.postal_code,
          date_of_birth: @form.date_of_birth,
          gender: @form.gender,
          age_range: @form.age_range,
          phone_number: @form.phone_number,
          location: @form.location,
          underage: @form.underage,
          select_fields: @form.select_fields,
          boolean_fields: @form.boolean_fields,
          text_fields: @form.text_fields,
          statutory_representative_email: @form.statutory_representative_email
        )
      end
    end
  end
end
