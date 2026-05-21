# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Produces a PivotTable that cross-tabulates a participation metric
    # against two user-profile dimensions within a single participatory space.
    class PivotTableBuilder
      # @param participatory_space [Decidim::ParticipatoryProcess, Decidim::Assembly]
      # @param metric_name [String] registered metric name (see InsightMetrics)
      # @param row_field [String] extra user field for the Y axis
      # @param col_field [String] extra user field for the X axis
      def initialize(participatory_space:, metric_name:, row_field:, col_field:)
        @participatory_space = participatory_space
        @metric_name = metric_name
        @row_field_obj = InsightFields.for(row_field)
        @col_field_obj = InsightFields.for(col_field)
      end

      # @return [Decidim::ExtraUserFields::PivotTable]
      def call
        metric_data = run_metric
        return empty_pivot_table if metric_data.empty?

        users = load_users(metric_data.keys)
        cells = build_cells(metric_data, users)

        row_vals = merge_ordered_values(cells.keys, row_field_obj)
        col_vals = merge_ordered_values(cells.values.flat_map(&:keys).uniq, col_field_obj)

        PivotTable.new(row_values: row_vals, col_values: col_vals, cells: cells)
      end

      private

      attr_reader :participatory_space, :metric_name, :row_field_obj, :col_field_obj

      def run_metric
        klass = InsightMetrics.metric_class(metric_name)
        return {} unless klass

        klass.new(participatory_space).call
      end

      def load_users(user_ids)
        Decidim::User
          .where(id: user_ids)
          .pluck(:id, :extended_data)
          .to_h
      end

      def build_cells(metric_data, users)
        cells = Hash.new { |h, k| h[k] = Hash.new(0) }

        metric_data.each do |user_id, count|
          extended_data = (users[user_id] || {}).with_indifferent_access
          row_val = row_field_obj.extract(extended_data)
          col_val = col_field_obj.extract(extended_data)

          cells[row_val][col_val] += count
        end

        cells
      end

      def empty_pivot_table
        PivotTable.new(row_values: [], col_values: [], cells: {})
      end

      # Merges configured ordered values into the data values so categories
      # without data still appear in the pivot table axes.
      def merge_ordered_values(data_values, field_obj)
        ordered = field_obj.ordered_values
        all = if ordered
                (ordered | data_values).compact.uniq
              else
                data_values.compact.uniq
              end
        has_nil = data_values.include?(nil)
        sorted = all.sort_by { |v| sort_index(v, ordered) }
        has_nil ? sorted + [nil] : sorted
      end

      # Returns a sort key for a value given an optional ordered list.
      # Values in the list sort by index; unknown values sort after all known ones alphabetically.
      def sort_index(value, ordered)
        if ordered
          index = ordered.index(value.to_s)
          index ? [0, index] : [0, ordered.size, value.to_s]
        else
          [0, 0, value.to_s]
        end
      end
    end
  end
end
