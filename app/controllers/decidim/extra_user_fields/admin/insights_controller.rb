# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class InsightsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::ParticipatorySpaceAdminContext
        include PivotParamsConcern
        participatory_space_admin_layout
        helper InsightsHelper

        helper_method :pivot_table_presenter

        before_action :set_breadcrumbs

        def show
          enforce_permission_to :read, :insights
        end

        def export
          enforce_permission_to :export, :insights

          ExportPivotData.call(
            params[:export_format],
            current_user,
            [current_participatory_space],
            pivot_params,
            export_name: "insights"
          ) do
            on(:ok) do
              flash[:notice] = t("decidim.admin.exports.notice")
              redirect_back(fallback_location: root_path)
            end
          end
        end

        private

        def pivot_table_presenter
          @pivot_table_presenter ||= PivotTablePresenter.new(
            PivotTableBuilder.new(
              participatory_space: current_participatory_space,
              metric_name: current_metric,
              row_field: current_row_field,
              col_field: current_col_field
            ).call
          )
        end

        def permission_class_chain
          [
            ::Decidim::ExtraUserFields::Admin::Permissions,
            current_participatory_space.manifest.permissions_class,
            ::Decidim::Admin::Permissions
          ]
        end

        def current_participatory_space
          @current_participatory_space ||= find_participatory_space_from_params
        end

        def find_participatory_space_from_params
          Decidim.participatory_space_manifests.each do |manifest|
            model_name = manifest.model_class_name.demodulize.underscore
            slug = params["#{model_name}_slug"]
            next if slug.blank?

            return manifest.model_class_name.constantize.find_by!(organization: current_organization, slug:)
          end

          raise ActiveRecord::RecordNotFound, "No participatory space found"
        end

        def set_breadcrumbs
          Decidim.participatory_space_manifests.each do |manifest|
            model_name = manifest.model_class_name.demodulize.underscore
            next if params["#{model_name}_slug"].blank?

            secondary_breadcrumb_menus << :"admin_#{model_name}_menu"
            break
          end
        end
      end
    end
  end
end
