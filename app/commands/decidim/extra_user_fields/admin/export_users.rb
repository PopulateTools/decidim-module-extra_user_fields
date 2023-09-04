# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # Command to export organization users from the participants admin panel.
      class ExportUsers < Decidim::Command
        # format - a string representing the export format
        # current_user - the user performing the action
        def initialize(format, current_user)
          @format = format
          @current_user = current_user
        end

        # Exports the current organization not deleted users.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          broadcast(:ok, export_data)
        end

        private

        attr_reader :current_user, :format

        def export_data
          Decidim.traceability.perform_action!(
            :export_users,
            current_organization,
            current_user
          ) do
            Decidim::Exporters
              .find_exporter(format)
              .new(collection, Decidim::ExtraUserFields::UserExportSerializer)
              .export
          end
        end

        def collection
          current_organization.users.not_deleted
        end
      end
    end
  end
end
