# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module ExtraUserFields
    # This is the engine that runs on the public interface of extra_user_fields.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ExtraUserFields

      routes do
        # Add engine routes here
        # resources :extra_user_fields
        # root to: "extra_user_fields#index"
      end

      initializer "decidim_extra_user_fields.assets" do |app|
        app.config.assets.precompile += %w[decidim_extra_user_fields_manifest.js decidim_extra_user_fields_manifest.css]
      end
    end
  end
end
