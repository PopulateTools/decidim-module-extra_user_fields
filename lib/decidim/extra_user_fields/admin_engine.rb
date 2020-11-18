# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # This is the engine that runs on the public interface of `ExtraUserFields`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ExtraUserFields::Admin

      DEFAULT_EXPORT_FORMATS = %w(CSV JSON Excel).freeze

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        namespace :extra_user_fields do
          get :export_users
        end
      end

      initializer "decidim_extra_user_fields.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ExtraUserFields::AdminEngine, at: "/admin/extra_user_fields", as: "decidim_extra_user_fields"
        end
      end

      initializer "decidim_extra_user_fields.admin_export_users" do
        Decidim::Admin::ApplicationHelper.class_eval do
          include ExtraUserFields::Admin::ApplicationHelper
        end
      end

      def load_seed
        nil
      end
    end
  end
end
