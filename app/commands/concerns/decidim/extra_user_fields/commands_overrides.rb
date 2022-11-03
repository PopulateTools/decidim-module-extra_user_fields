# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module CommandsOverrides
      extend ActiveSupport::Concern

      private

      def create_user
        @user = User.create!(
          email: @form.email,
          name: @form.name,
          nickname: @form.nickname,
          password: @form.password,
          password_confirmation: @form.password_confirmation,
          organization: @form.current_organization,
          tos_agreement: @form.tos_agreement,
          newsletter_notifications_at: @form.newsletter_at,
          email_on_notification: true,
          accepted_tos_version: @form.current_organization.tos_version,
          locale: @form.current_locale,
          extended_data: extended_data
        )
      end

      def update_personal_data
        @user.name = @form.name
        @user.nickname = @form.nickname
        @user.email = @form.email
        @user.personal_url = @form.personal_url
        @user.about = @form.about
        @user.extended_data = extended_data
      end

      # rubocop:disable Style/TrailingCommaInArguments
      def extended_data
        @extended_data ||= (@user&.extended_data || {}).merge(
          country: @form.country,
          postal_code: @form.postal_code,
          date_of_birth: @form.date_of_birth,
          gender: @form.gender,
          # Block ExtraUserFields SaveInExtendedData
          # EndBlock
        )
      end
      # rubocop:enable Style/TrailingCommaInArguments
    end
  end
end
