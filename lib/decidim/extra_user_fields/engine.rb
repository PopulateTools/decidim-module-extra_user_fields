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

      routes do
        # Add engine routes here
        # resources :extra_user_fields
        # root to: "extra_user_fields#index"
      end

      initializer "decidim_extra_user_fields.registration_additions" do
        config.to_prepare do
          Decidim::RegistrationForm.class_eval do
            include ExtraUserFields::FormsDefinitions
          end

          Decidim::OmniauthRegistrationForm.class_eval do
            include ExtraUserFields::FormsDefinitions
          end

          Decidim::AccountForm.class_eval do
            include ExtraUserFields::FormsDefinitions
          end

          Decidim::CreateRegistration.class_eval do
            prepend ExtraUserFields::CommandsOverrides
          end

          Decidim::CreateOmniauthRegistration.class_eval do
            prepend ExtraUserFields::OmniauthCommandsOverrides
          end

          Decidim::UpdateAccount.class_eval do
            prepend ExtraUserFields::CommandsOverrides
          end

          Decidim::Organization.class_eval do
            prepend ExtraUserFields::OrganizationOverrides
          end

          Decidim::FormBuilder.class_eval do
            include ExtraUserFields::FormBuilderMethods
          end

          Decidim::FormBuilder.class_eval do
            include ExtraUserFields::FormBuilderMethods
          end
        end
      end
    end
  end
end
