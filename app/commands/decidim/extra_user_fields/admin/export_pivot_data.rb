# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # Unified command to export pivot table data for both Insights (single space)
      # and Benchmarking (multiple spaces).
      class ExportPivotData < Decidim::Command
        # Public: Initializes the command.
        #
        # format       - A String with the export format (CSV, JSON, Excel).
        # current_user - The user performing the export.
        # spaces       - An Array of participatory spaces.
        # pivot_params - A Hash with :metric, :row_field, :col_field.
        # export_name  - A String label for the export (e.g. "insights", "benchmarking").
        def initialize(format, current_user, spaces, pivot_params, export_name:)
          @format = format
          @current_user = current_user
          @spaces = spaces
          @pivot_params = pivot_params
          @export_name = export_name
        end

        def call
          traceability_target = spaces.size == 1 ? spaces.first : current_user.organization

          Decidim.traceability.perform_action!(
            :"export_#{export_name}",
            traceability_target,
            current_user
          ) do
            ExportPivotDataJob.perform_later(current_user, format, spaces, pivot_params, export_name)
          end

          broadcast(:ok)
        end

        private

        attr_reader :format, :current_user, :spaces, :pivot_params, :export_name
      end
    end
  end
end
