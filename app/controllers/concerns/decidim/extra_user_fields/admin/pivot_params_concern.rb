# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      module PivotParamsConcern
        extend ActiveSupport::Concern

        included do
          helper_method :current_metric, :current_row_field, :current_col_field,
                        :available_metrics, :available_fields
        end

        private

        def current_metric
          @current_metric ||= detect_metric(params[:metric]) || available_metrics.first
        end

        def current_row_field
          @current_row_field ||= detect_field(params[:rows]) || available_fields.second || available_fields.first
        end

        def current_col_field
          @current_col_field ||= detect_field(params[:cols]) || available_fields.first
        end

        def available_metrics
          @available_metrics ||= InsightMetrics.available_metrics
        end

        def available_fields
          @available_fields ||= Decidim::ExtraUserFields.insight_fields
        end

        def pivot_params
          { metric: current_metric, row_field: current_row_field, col_field: current_col_field }
        end

        def detect_metric(name)
          name = name.to_s
          name if InsightMetrics.valid_metric?(name)
        end

        def detect_field(name)
          name = name.to_s
          name if available_fields.include?(name)
        end
      end
    end
  end
end
