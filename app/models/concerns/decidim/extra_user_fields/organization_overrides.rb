# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module OrganizationOverrides
      extend ActiveSupport::Concern

      # If true display registration field in signup form
      def extra_user_fields_enabled?
        activated_extra_field?(:enabled)
      end

      # Check if the given value is enabled in extra_user_fields
      def activated_extra_field?(sym)
        return false if extra_user_fields[sym.to_s].blank?

        extra_user_fields[sym.to_s]
      end
    end
  end
end
