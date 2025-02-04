# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module CreateRegistrationsCommandsOverrides
      extend ActiveSupport::Concern

      def call
        return broadcast(:invalid) if same_email_representative?

        if form.invalid?

          user = User.has_pending_invitations?(form.current_organization.id, form.email)
          user.invite!(user.invited_by) if user
          return broadcast(:invalid)
        end

        create_user
        send_email_to_statutory_representative

        broadcast(:ok, @user)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      def create_user
        @user = User.create!(
          email: form.email,
          name: form.name,
          nickname: form.nickname,
          password: form.password,
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
          location: form.location,
          underage: form.underage,
          statutory_representative_email: form.statutory_representative_email
        )
      end

      def send_email_to_statutory_representative
        return if form.statutory_representative_email.blank? || form.underage != "1"

        Decidim::ExtraUserFields::StatutoryRepresentativeMailer.inform(@user).deliver_later
      end

      def same_email_representative?
        return false if form.statutory_representative_email.blank?

        form.statutory_representative_email == form.email
      end
    end
  end
end
