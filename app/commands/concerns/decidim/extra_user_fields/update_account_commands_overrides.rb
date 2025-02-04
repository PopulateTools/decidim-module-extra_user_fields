# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module UpdateAccountCommandsOverrides
      extend ActiveSupport::Concern

      private

      def update_personal_data
        @user.locale = @form.locale
        @user.name = @form.name
        @user.nickname = @form.nickname
        @user.email = @form.email
        @user.personal_url = @form.personal_url
        @user.about = @form.about
        @user.extended_data = extended_data
      end

      def extended_data
        @extended_data ||= (@user&.extended_data || {}).merge(
          country: @form.country,
          postal_code: @form.postal_code,
          date_of_birth: @form.date_of_birth,
          gender: @form.gender,
          phone_number: @form.phone_number,
          location: @form.location,
          underage: @form.underage,
          statutory_representative_email: @form.statutory_representative_email
        )
      end
    end
  end
end
