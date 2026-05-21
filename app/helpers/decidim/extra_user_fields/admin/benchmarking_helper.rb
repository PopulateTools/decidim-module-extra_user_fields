# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      module BenchmarkingHelper
        # Label for the multi-select dropdown: "[Process] My Title"
        def space_option_label(space)
          type = space.class.model_name.human
          title = space.title.is_a?(Hash) ? (space.title[I18n.locale.to_s] || space.title.values.first) : space.title.to_s
          "[#{type}] #{title}"
        end

        def space_option_value(space)
          "#{space.class.name}:#{space.id}"
        end

        def benchmarking_data_cell(space, row, col, space_index:, col_index:)
          value = comparative_pivot_presenter.cell(space, row, col)
          cell_type = row.nil? || col.nil? ? "gray" : "colored"
          css = "insights-table__cell heatmap-cell--#{cell_type}"
          css += " insights-table__space-divider" if col_index.zero? && space_index.positive?

          content_tag(:td, number_with_delimiter(value),
                      class: css,
                      style: comparative_pivot_presenter.cell_style(value, row, col))
        end

        def benchmarking_row_total_cell(row)
          value = comparative_pivot_presenter.combined_row_total(row)
          content_tag(:td, number_with_delimiter(value),
                      class: "insights-table__row-total heatmap-total",
                      style: comparative_pivot_presenter.row_total_style(value))
        end

        def benchmarking_col_total_cell(space, col, space_index:, col_index:)
          value = comparative_pivot_presenter.space_col_total(space, col)
          css = "insights-table__col-total heatmap-total"
          css += " insights-table__space-divider" if col_index.zero? && space_index.positive?

          content_tag(:td, number_with_delimiter(value),
                      class: css,
                      style: comparative_pivot_presenter.col_total_style(value))
        end

        def space_name(space, limit: 40)
          full = comparative_pivot_presenter.space_label(space)
          return full if full.length <= limit

          content_tag(:span, truncate(full, length: limit), title: full, style: "cursor: help")
        end

        def benchmarking_grand_total_cell
          content_tag(:td, number_with_delimiter(comparative_pivot_presenter.combined_grand_total),
                      class: "insights-table__grand-total")
        end

        def benchmarking_export_dropdown
          export_name = t("decidim.admin.extra_user_fields.benchmarking.export_name")
          base_params = {
            metric: current_metric,
            rows: current_row_field,
            cols: current_col_field,
            spaces: selected_spaces.map { |s| space_option_value(s) }
          }

          export_dropdown(dropdown_id: "benchmarking-export-dropdown") do |fmt|
            label = t("decidim.admin.exports.export_as", name: export_name, export_format: fmt)
            url = AdminEngine.routes.url_helpers.benchmarking_export_path(**base_params, export_format: fmt)
            [label, url, :post]
          end
        end
      end
    end
  end
end
