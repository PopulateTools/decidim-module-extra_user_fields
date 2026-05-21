# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class BenchmarkingController < Decidim::Admin::ApplicationController
        include PivotParamsConcern
        layout "decidim/admin/insights"

        helper InsightsHelper
        helper BenchmarkingHelper

        helper_method :comparative_pivot_presenter, :selected_spaces, :available_spaces

        def show
          enforce_permission_to :read, :insights
        end

        def export
          enforce_permission_to :export, :insights

          ExportPivotData.call(
            params[:export_format],
            current_user,
            selected_spaces,
            pivot_params,
            export_name: "benchmarking"
          ) do
            on(:ok) do
              flash[:notice] = t("decidim.admin.exports.notice")
              redirect_back(fallback_location: decidim_extra_user_fields.benchmarking_path)
            end
          end
        end

        private

        def comparative_pivot_presenter
          @comparative_pivot_presenter ||= ComparativePivotPresenter.new(
            pivot_tables_by_space,
            row_field: current_row_field,
            col_field: current_col_field
          )
        end

        def pivot_tables_by_space
          selected_spaces.index_with do |space|
            PivotTableBuilder.new(
              participatory_space: space,
              metric_name: current_metric,
              row_field: current_row_field,
              col_field: current_col_field
            ).call
          end
        end

        def selected_spaces
          @selected_spaces ||= parse_selected_spaces
        end

        def available_spaces
          @available_spaces ||= Decidim.participatory_space_manifests.flat_map do |manifest|
            manifest.model_class_name.constantize.where(organization: current_organization)
          end
        end

        def permission_class_chain
          [
            ::Decidim::ExtraUserFields::Admin::Permissions,
            ::Decidim::Admin::Permissions
          ]
        end

        def parse_selected_spaces
          return [] if params[:spaces].blank?

          params[:spaces].filter_map do |key|
            klass_name, _, id = key.rpartition(":")
            next unless id.present? && klass_name.present?
            next unless Decidim.participatory_space_manifests.any? { |m| m.model_class_name == klass_name }

            klass_name.constantize.find_by(id: id, organization: current_organization)
          end
        end
      end
    end
  end
end
