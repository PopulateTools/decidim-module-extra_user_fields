# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        def extra_user_fields_export_users_dropdown
          content_tag(:ul, class: "vertical menu add-components") do
            Decidim::ExtraUserFields::AdminEngine::DEFAULT_EXPORT_FORMATS.map do |format|
              content_tag(:li, class: "exports--format--#{format.downcase} export--users") do
                link_to(
                  t("decidim.admin.exports.export_as", name: t("decidim.extra_user_fields.admin.exports.users"), export_format: format.upcase),
                  AdminEngine.routes.url_helpers.extra_user_fields_export_users_path(format: format)
                )
              end
            end.join.html_safe
          end
        end
      end
    end
  end
end
