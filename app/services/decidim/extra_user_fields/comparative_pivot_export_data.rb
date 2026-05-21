# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Converts a ComparativePivotPresenter into an array of hashes for export.
    # Handles both single-space (no prefix) and multi-space
    # (space prefix, per-space totals, combined row total) layouts.
    class ComparativePivotExportData
      def initialize(presenter)
        @presenter = presenter
        @row_field_obj = InsightFields.for(presenter.row_field)
        @col_field_obj = InsightFields.for(presenter.col_field)
      end

      def row_header_key
        @row_header_key ||= "#{i18n_field_label(presenter.row_field)} / #{i18n_field_label(presenter.col_field)}"
      end

      def rows
        data_rows + [totals_row]
      end

      private

      attr_reader :presenter, :row_field_obj, :col_field_obj

      delegate :spaces, :unified_row_values, :unified_col_values, to: :presenter

      def single_space?
        spaces.size == 1
      end

      def data_rows
        unified_row_values.map do |row_val|
          row = { row_header_key => row_label(row_val) }

          spaces.each do |space|
            append_columns(row, space) { |col_val| presenter.cell(space, row_val, col_val) }
            row[space_total_header(space)] = presenter.space_row_total(space, row_val)
          end

          row[row_total_label] = presenter.combined_row_total(row_val) unless single_space?
          row
        end
      end

      def totals_row
        row = { row_header_key => I18n.t("decidim.admin.extra_user_fields.insights.column_total") }

        spaces.each do |space|
          append_columns(row, space) { |col_val| presenter.space_col_total(space, col_val) }
          row[space_total_header(space)] = presenter.space_grand_total(space)
        end

        row[row_total_label] = presenter.combined_grand_total unless single_space?
        row
      end

      def append_columns(row, space)
        unified_col_values.each do |col_val|
          row[col_header(col_val, space)] = yield(col_val)
        end
      end

      def col_header(col_val, space)
        label = col_label(col_val)
        single_space? ? label : "[#{presenter.space_label(space)}] / #{label}"
      end

      def space_total_header(space)
        single_space? ? row_total_label : "[#{presenter.space_label(space)}] / #{row_total_label}"
      end

      def row_label(value)
        value.nil? ? non_specified_label : row_field_obj.value_label(value)
      end

      def col_label(value)
        value.nil? ? non_specified_label : col_field_obj.value_label(value)
      end

      def row_total_label
        @row_total_label ||= I18n.t("decidim.admin.extra_user_fields.insights.row_total")
      end

      def non_specified_label
        I18n.t("decidim.admin.extra_user_fields.insights.non_specified")
      end

      def i18n_field_label(field_name)
        I18n.t("decidim.admin.extra_user_fields.insights.fields.#{field_name}", default: field_name.humanize)
      end
    end
  end
end
