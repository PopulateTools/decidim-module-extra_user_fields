# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module CreateRegistrationsCommandsOverrides
      extend ActiveSupport::Concern

      private

      def create_user
        @user = User.create!(
          email: form.email,
          name: form.name,
          nickname: form.nickname,
          password: form.password,
          password_confirmation: form.password_confirmation,
          password_updated_at: Time.current,
          organization: form.current_organization,
          tos_agreement: form.tos_agreement,
          newsletter_notifications_at: form.newsletter_at,
          accepted_tos_version: form.current_organization.tos_version,
          locale: form.current_locale,
          extended_data:
        )
      end

      def extended_data
        @extended_data ||= (@user&.extended_data || {}).merge(
          country: form.country,
          postal_code: form.postal_code,
          date_of_birth: form.date_of_birth,
          gender: form.gender,
          phone_number: form.phone_number,
          location: form.location
        )
      end
    end
  end
end
