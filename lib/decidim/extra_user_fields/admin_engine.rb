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
        namespace :extra_user_fields do
          get :export_users
        end

        resources :extra_user_fields, only: [:index]
        match "/extra_user_fields" => "extra_user_fields#update", :via => :patch, :as => "update"

        get "benchmarking", to: "benchmarking#show"
        post "benchmarking/export", to: "benchmarking#export", as: :benchmarking_export

        root to: "extra_user_fields#index"
      end

      initializer "decidim_extra_user_fields.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ExtraUserFields::AdminEngine, at: "/admin/extra_user_fields", as: "decidim_extra_user_fields"
        end
      end

      initializer "decidim_extra_user_fields.admin_export_users" do
        config.to_prepare do
          Decidim::Admin::ApplicationHelper.class_eval do
            include ExtraUserFields::Admin::ApplicationHelper
          end
        end
      end

      initializer "decidim_extra_user_fields.admin_user_menu" do
        Decidim.menu :admin_user_menu do |menu|
          menu.add_item :extra_user_fields,
                        t("decidim.admin.extra_user_fields.menu.title"),
                        decidim_extra_user_fields.root_path,
                        position: 5,
                        icon_name: "list-check"
        end
      end

      initializer "decidim_extra_user_fields.admin_insights_menu" do
        Decidim.menu :admin_insights_menu do |menu|
          menu.add_item :benchmarking,
                        t("decidim.admin.extra_user_fields.benchmarking.menu_title"),
                        decidim_extra_user_fields.benchmarking_path,
                        position: 2,
                        icon_name: "bar-chart-box-line",
                        active: is_active_link?(decidim_extra_user_fields.benchmarking_path)
        end

        Decidim.menu :admin_menu do |menu|
          menu.remove_item :insights

          menu.add_item :insights_with_benchmarking,
                        I18n.t("menu.insights", scope: "decidim.admin"),
                        decidim_admin.statistics_path,
                        icon_name: "line-chart",
                        position: 11,
                        if: allowed_to?(:read, :statistics),
                        active: [
                          %w(
                            decidim/admin/statistics
                            decidim/demographics/admin/settings
                            decidim/demographics/admin/questions
                            decidim/demographics/admin/responses
                            decidim/demographics/admin/publish_responses
                            decidim/extra_user_fields/admin/benchmarking
                          ), []
                        ]
        end
      end

      initializer "decidim_extra_user_fields.insights_routes" do
        Decidim::Core::Engine.routes do
          Decidim.participatory_space_manifests.each do |manifest|
            model_name = manifest.model_class_name.demodulize.underscore
            slug_param = "#{model_name}_slug"

            scope "/admin/#{manifest.name}/:#{slug_param}" do
              mount Decidim::ExtraUserFields::InsightsEngine,
                    at: "/insights",
                    as: "decidim_admin_#{model_name}_insights"
            end
          end
        end
      end

      initializer "decidim_extra_user_fields.insights_menu" do
        Decidim.participatory_space_manifests.each do |manifest|
          model_name = manifest.model_class_name.demodulize.underscore
          slug_param = "#{model_name}_slug"
          menu_name = :"admin_#{model_name}_menu"
          route_helper = "decidim_admin_#{model_name}_insights"

          Decidim.menu menu_name do |menu|
            menu.add_item :insights,
                          I18n.t("decidim.admin.extra_user_fields.insights.menu_title"),
                          send(route_helper).root_path(slug_param => current_participatory_space.slug),
                          icon_name: "bar-chart-2-line",
                          position: 9
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end
