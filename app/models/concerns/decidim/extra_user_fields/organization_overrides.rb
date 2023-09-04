# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ExtraUserFields
    # Changes in methods to store extra fields in user profile
    module OrganizationOverrides
      extend ActiveSupport::Concern

      # If true display registration field in signup form
      def extra_user_fields_enabled?
        extra_user_fields["enabled"].presence && at_least_one_extra_field?
      end

      def at_least_one_extra_field?
        extra_user_fields.reject { |key| key == "enabled" }
                         .map { |_, value| value["enabled"] }.any?
      end

      # Check if the given value is enabled in extra_user_fields
      def activated_extra_field?(sym)
        extra_user_fields.dig(sym.to_s, "enabled") == true
      end
    end
  end
end
