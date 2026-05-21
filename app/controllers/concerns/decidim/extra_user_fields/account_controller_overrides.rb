# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Overrides AccountController#show to trigger validation
    # when the user has incomplete mandatory extra user fields.
    # This makes the form render with error highlights on load.
    module AccountControllerOverrides
      extend ActiveSupport::Concern

      def show
        super

        return unless current_organization.respond_to?(:has_required_extra_user_fields?)
        return unless current_organization.has_required_extra_user_fields?
        return if current_organization.extra_user_fields_complete?(current_user)

        @account.validate
      end
    end
  end
end
