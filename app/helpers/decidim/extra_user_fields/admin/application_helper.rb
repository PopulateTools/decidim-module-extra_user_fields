# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      module ApplicationHelper
        # Renders an export dropdown button with format options.
        #
        # dropdown_id - A String with the unique HTML id for the dropdown menu.
        # formats     - An Array of format strings (defaults to DEFAULT_EXPORT_FORMATS).
        # block       - Yields each format, must return [label, url] or [label, url, http_method].
        #
        # Returns an ActiveSupport::SafeBuffer.
        def export_dropdown(dropdown_id: "export-dropdown", formats: AdminEngine::DEFAULT_EXPORT_FORMATS, &block)
          button = content_tag(:button,
                               class: "button button__sm button__transparent-secondary",
                               data: { controller: "dropdown", target: dropdown_id }) do
            safe_join([
                        t("actions.export", scope: "decidim.admin"),
                        icon("arrow-down-s-line"),
                        icon("arrow-down-s-line")
                      ])
          end

          items = formats.map do |fmt|
            label, url, http_method = block.call(fmt)
            link_opts = { class: "dropdown__button" }
            link_opts[:method] = http_method if http_method
            content_tag(:li, class: "dropdown__item") do
              link_to(label, url, **link_opts)
            end
          end

          menu = content_tag(:ul, id: dropdown_id, class: "dropdown dropdown__bottom", aria: { hidden: true }) do
            safe_join(items)
          end

          content_tag(:div, class: "relative") { button + menu }
        end

        # Renders the export dropdown for the users list.
        def users_export_dropdown
          export_name = t("decidim.extra_user_fields.admin.exports.users")

          export_dropdown(dropdown_id: "export-users-dropdown") do |fmt|
            label = t("decidim.admin.exports.export_as", name: export_name, export_format: fmt)
            url = AdminEngine.routes.url_helpers.extra_user_fields_export_users_path(format: fmt)
            [label, url]
          end
        end
      end
    end
  end
end
