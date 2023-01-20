# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :extra_user_fields_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :extra_user_fields).i18n_name }
    manifest_name { :extra_user_fields }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
