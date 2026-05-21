# frozen_string_literal: true

module Decidim
  # This holds the decidim-extra_user_fields version.
  module ExtraUserFields
    def self.version
      "0.31.0"
    end

    def self.decidim_version
      [">= 0.31"].freeze
    end
  end
end
