# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      class ExtraUserFieldsController < Admin::ApplicationController
        layout "decidim/admin/settings"

        def index
          enforce_permission_to :read, :extra_user_fields

          @form = form(ExtraUserFieldsForm).from_model(current_organization)
        end

        def update
          enforce_permission_to :update, :extra_user_fields

          @form = form(ExtraUserFieldsForm).from_params(
            params,
            current_organization:
          )

          UpdateExtraUserFields.call(@form) do
            on(:ok) do
              flash[:notice] = t(".success")
              render action: "index"
            end

            on(:invalid) do
              flash.now[:alert] = t(".failure")
              render action: "index"
            end
          end
        end

        def export_users
          enforce_permission_to :read, :officialization

          Decidim.traceability.perform_action!("export_users", current_organization, current_user, { format: params[:format] }) do
            ExportParticipantsJob.perform_later(current_organization, current_user, params[:format])
          end

          flash[:notice] = t("decidim.admin.exports.notice")
          redirect_to engine_routes.officializations_path
        end

        private

        def engine_routes
          Decidim::Admin::Engine.routes.url_helpers
        end
      end
    end
  end
end
