# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Computes heatmap intensity for PivotTable cells using min-max normalization.
    # Outputs CSS custom properties consumed by SCSS:
    #   --i  = intensity (0.0–1.0), drives the color gradient
    #   --tc = text color (#fff or #1a1a1a), ensures contrast on colored backgrounds
    class PivotTablePresenter
      include HeatmapIntensity

      delegate :row_values, :col_values, :cell, :row_total, :col_total,
               :grand_total, :empty?, :max_value, to: :pivot_table

      def initialize(pivot_table)
        @pivot_table = pivot_table
      end

      # CSS variables for a data cell. Gray cells (nil row/col) normalize
      # against all cells; colored cells against specified (non-nil) cells only.
      def cell_style(value, row, col)
        if row.nil? || col.nil?
          intensity_vars(value, *pivot_table.all_cell_range)
        else
          intensity_vars(value, *pivot_table.specified_cell_range)
        end
      end

      def row_total_style(value)
        total_intensity_vars(value, pivot_table.row_total_max)
      end

      def col_total_style(value)
        total_intensity_vars(value, pivot_table.col_total_max)
      end

      private

      attr_reader :pivot_table
    end
  end
end
