# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Settings
      include ActiveSupport::Configurable

      config_accessor :interests do
        []
      end
    end
  end
end
