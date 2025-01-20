# frozen_string_literal: true

require "rails"
require "decidim/core"
require "country_select"
require "deface"

module Decidim
  module ExtraUserFields
    # This is the engine that runs on the public interface of extra_user_fields.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ExtraUserFields

      DEFAULT_GENDER_OPTIONS = [:male, :female, :other].freeze

      DEFAULT_UNDERAGE_LIMIT = 18

      DEFAULT_UNDERAGE_OPTIONS = (15..21)

      routes do
        # Add engine routes here
        # resources :extra_user_fields
        # root to: "extra_user_fields#index"
        get "underage_limit", to: "extra_user_fields#retrieve_underage_limit", as: :retrieve_underage_limit
      end

      initializer "decidim_extra_user_fields.registration_additions" do
        config.to_prepare do
          Decidim::RegistrationForm.class_eval do
            include Decidim::ExtraUserFields::FormsDefinitions
          end

          Decidim::OmniauthRegistrationForm.class_eval do
            include Decidim::ExtraUserFields::FormsDefinitions
          end

          Decidim::AccountForm.class_eval do
            include Decidim::ExtraUserFields::FormsDefinitions
          end

          Decidim::CreateRegistration.class_eval do
            prepend Decidim::ExtraUserFields::CreateRegistrationsCommandsOverrides
          end

          Decidim::CreateOmniauthRegistration.class_eval do
            prepend Decidim::ExtraUserFields::OmniauthCommandsOverrides
          end

          Decidim::UpdateAccount.class_eval do
            prepend Decidim::ExtraUserFields::UpdateAccountCommandsOverrides
          end

          Decidim::Organization.class_eval do
            prepend Decidim::ExtraUserFields::OrganizationOverrides
          end

          Decidim::FormBuilder.class_eval do
            include Decidim::ExtraUserFields::FormBuilderMethods
          end
        end
      end

      initializer "decidim_extra_user_fields.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ExtraUserFields::Engine, at: "/extra_user_fields", as: "decidim_extra_user_fields_engine"
        end
      end
    end
  end
end
