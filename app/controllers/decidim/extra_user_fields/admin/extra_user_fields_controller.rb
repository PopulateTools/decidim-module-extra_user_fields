# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      class ExtraUserFieldsController < Admin::ApplicationController
        def export_users
          enforce_permission_to :read, :officialization

          ExportUsers.call(params[:format], current_user) do
            on(:ok) do |export_data|
              send_data export_data.read, type: "text/#{export_data.extension}", filename: export_data.filename("participants")
            end
          end
        end
      end
    end
  end
end
