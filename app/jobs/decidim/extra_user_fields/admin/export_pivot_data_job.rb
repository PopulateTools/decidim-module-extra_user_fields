# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExportPivotDataJob < ApplicationJob
        include Decidim::PrivateDownloadHelper

        queue_as :exports

        def perform(user, format, spaces, pivot_params, export_name)
          row_field = pivot_params[:row_field]
          col_field = pivot_params[:col_field]

          pivot_tables_by_space = spaces.index_with do |space|
            PivotTableBuilder.new(
              participatory_space: space,
              metric_name: pivot_params[:metric],
              row_field:,
              col_field:
            ).call
          end

          presenter = ComparativePivotPresenter.new(pivot_tables_by_space, row_field:, col_field:)
          collection = ComparativePivotExportData.new(presenter).rows
          export_data = Decidim::Exporters.find_exporter(format).new(collection, PivotTableRowSerializer).export

          private_export = attach_archive(export_data, export_name, user)
          ExportMailer.export(user, private_export).deliver_later
        end
      end
    end
  end
end
