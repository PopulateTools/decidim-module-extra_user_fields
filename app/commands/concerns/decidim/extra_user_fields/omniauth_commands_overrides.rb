# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module OmniauthCommandsOverrides
      extend ActiveSupport::Concern

      def call
        return broadcast(:invalid) if same_email_representative?

        verify_oauth_signature!

        begin
          if (@identity = existing_identity)
            @user = existing_identity.user
            verify_user_confirmed(@user)
            trigger_omniauth_event("decidim.user.omniauth_login")

            return broadcast(:ok, @user)
          end

          return broadcast(:invalid) if form.invalid?

          transaction do
            create_or_find_user
            send_email_to_statutory_representative
            @identity = create_identity
          end
          trigger_omniauth_event

          broadcast(:ok, @user)
        rescue Decidim::NeedTosAcceptance
          broadcast(:add_tos_errors, @user)
        rescue ActiveRecord::RecordInvalid => e
          broadcast(:error, e.record)
        end
      end

      private

      attr_reader :form, :verified_email

      REGEXP_SANITIZER = /[<>?%&\^*#@()\[\]=+:;"{}\\|]/

      def create_or_find_user
        @user = User.find_or_initialize_by(
          email: verified_email,
          organization:
        )

        if @user.persisted?
          # If user has left the account unconfirmed and later on decides to sign
          # in with omniauth with an already verified account, the account needs
          # to be marked confirmed.
          if !@user.confirmed? && @user.email == verified_email
            @user.skip_confirmation!
            @user.after_confirmation
          end
          @user.tos_agreement = "1"
          @user.extended_data = extended_data
          @user.save!
        else
          @user.email = (verified_email || form.email)
          @user.name = form.name.gsub(REGEXP_SANITIZER, "")
          @user.nickname = form.normalized_nickname
          @user.newsletter_notifications_at = form.newsletter_at
          @user.password = SecureRandom.hex
          attach_avatar(form.avatar_url) if form.avatar_url.present?
          @user.tos_agreement = form.tos_agreement
          @user.accepted_tos_version = Time.current
          raise NeedTosAcceptance if @user.tos_agreement.blank?

          @user.skip_confirmation! if verified_email
          @user.extended_data = extended_data
          @user.save!
          @user.after_confirmation if verified_email
        end
      end

      def extended_data
        @extended_data ||= (@user&.extended_data || {}).merge(
          country: form.country,
          postal_code: form.postal_code,
          date_of_birth: form.date_of_birth,
          gender: form.gender,
          age_range: form.age_range,
          phone_number: form.phone_number,
          location: form.location,
          underage: form.underage,
          select_fields: form.select_fields,
          boolean_fields: form.boolean_fields,
          text_fields: form.text_fields,
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
