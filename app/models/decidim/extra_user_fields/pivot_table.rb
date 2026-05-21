# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Value object representing a cross-tabulation (pivot) table.
    # Holds row values, column values, a 2D cell hash, and computed totals.
    class PivotTable
      attr_reader :row_values, :col_values, :cells

      # @param row_values [Array<String>] sorted unique values for the row axis
      # @param col_values [Array<String>] sorted unique values for the column axis
      # @param cells [Hash{String => Hash{String => Integer}}] cells[row][col] = count
      def initialize(row_values:, col_values:, cells:)
        @row_values = row_values
        @col_values = col_values
        @cells = cells
      end

      def cell(row, col)
        cells.dig(row, col) || 0
      end

      def row_total(row)
        row_totals[row]
      end

      def col_total(col)
        col_totals[col]
      end

      def grand_total
        @grand_total ||= row_totals.values.sum
      end

      def row_totals
        @row_totals ||= row_values.index_with do |row|
          col_values.sum { |col| cell(row, col) }
        end
      end

      def col_totals
        @col_totals ||= col_values.index_with do |col|
          row_values.sum { |row| cell(row, col) }
        end
      end

      def max_value
        @max_value ||= cells.values.flat_map(&:values).max || 0
      end

      def empty?
        grand_total.zero?
      end

      # Min-max among cells where both row and col are non-nil (specified).
      def specified_cell_range
        @specified_cell_range ||= positive_minmax(
          row_values.compact.flat_map { |row| col_values.compact.map { |col| cell(row, col) } }
        )
      end

      # Min-max among all cells (including nil row/col).
      def all_cell_range
        @all_cell_range ||= positive_minmax(cells.values.flat_map(&:values))
      end

      def row_total_max
        @row_total_max ||= row_values.map { |row| row_total(row) }.max || 0
      end

      def col_total_max
        @col_total_max ||= col_values.map { |col| col_total(col) }.max || 0
      end

      private

      def positive_minmax(values)
        non_zero = values.select(&:positive?)
        non_zero.empty? ? [0, 0] : non_zero.minmax
      end
    end
  end
end
