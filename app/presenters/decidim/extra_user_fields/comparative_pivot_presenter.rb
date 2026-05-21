# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Presents multiple PivotTables side by side for cross-space benchmarking.
    # Computes globally normalized heatmap intensities so all spaces are
    # visually comparable on the same scale.
    class ComparativePivotPresenter
      include HeatmapIntensity

      # @param pivot_tables [Hash{Object => PivotTable}] space => PivotTable
      # @param row_field [String] field name for the Y axis
      # @param col_field [String] field name for the X axis
      def initialize(pivot_tables, row_field:, col_field:)
        @pivot_tables = pivot_tables
        @row_field = row_field
        @col_field = col_field
      end

      attr_reader :pivot_tables, :row_field, :col_field

      def spaces
        pivot_tables.keys
      end

      # Unified row values across all spaces, preserving field order.
      def unified_row_values
        @unified_row_values ||= unify_values(:row_values)
      end

      # Unified column values across all spaces, preserving field order.
      def unified_col_values
        @unified_col_values ||= unify_values(:col_values)
      end

      def cell(space, row, col)
        pivot_tables[space]&.cell(row, col) || 0
      end

      def space_row_total(space, row)
        unified_col_values.sum { |col| cell(space, row, col) }
      end

      def space_col_total(space, col)
        unified_row_values.sum { |row| cell(space, row, col) }
      end

      def space_grand_total(space)
        unified_row_values.sum { |row| space_row_total(space, row) }
      end

      def combined_row_total(row)
        spaces.sum { |space| space_row_total(space, row) }
      end

      def combined_grand_total
        unified_row_values.sum { |row| combined_row_total(row) }
      end

      # CSS style for a data cell using global normalization.
      def cell_style(value, row, col)
        if row.nil? || col.nil?
          intensity_vars(value, *global_all_range)
        else
          intensity_vars(value, *global_specified_range)
        end
      end

      def row_total_style(value)
        total_intensity_vars(value, global_row_total_max)
      end

      def col_total_style(value)
        total_intensity_vars(value, global_col_total_max)
      end

      def empty?
        pivot_tables.values.all?(&:empty?)
      end

      def space_label(space)
        translated_name(space)
      end

      private

      # Min-max among cells where both row and col are non-nil, across all spaces.
      def global_specified_range
        @global_specified_range ||= begin
          values = spaces.flat_map do |space|
            unified_row_values.compact.flat_map do |row|
              unified_col_values.compact.map { |col| cell(space, row, col) }
            end
          end
          positive_minmax(values)
        end
      end

      # Min-max among all cells (including nil axes), across all spaces.
      def global_all_range
        @global_all_range ||= begin
          values = spaces.flat_map do |space|
            unified_row_values.flat_map do |row|
              unified_col_values.map { |col| cell(space, row, col) }
            end
          end
          positive_minmax(values)
        end
      end

      def global_row_total_max
        @global_row_total_max ||= unified_row_values.map { |row| combined_row_total(row) }.max || 0
      end

      def global_col_total_max
        @global_col_total_max ||= spaces.flat_map do |space|
          unified_col_values.map { |col| space_col_total(space, col) }
        end.max || 0
      end

      def positive_minmax(values)
        non_zero = values.select(&:positive?)
        non_zero.empty? ? [0, 0] : non_zero.minmax
      end

      # Merge axis values from all PivotTables, preserving order from the first
      # table that defines each value; nil always goes last.
      def unify_values(axis_method)
        seen = Set.new
        unified = []

        pivot_tables.each_value do |pt|
          pt.public_send(axis_method).each do |val|
            next if seen.include?(val)

            seen.add(val)
            unified << val
          end
        end

        # Ensure nil is always last
        if unified.include?(nil)
          unified.delete(nil)
          unified << nil
        end

        unified
      end

      def translated_name(space)
        space.title.is_a?(Hash) ? (space.title[I18n.locale.to_s] || space.title.values.first || "") : space.title.to_s
      end
    end
  end
end
