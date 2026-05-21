# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Engine for the Insights feature, mounted under participatory space admin URLs.
    # Provides pivot-table statistics scoped to a specific participatory space.
    class InsightsEngine < ::Rails::Engine
      isolate_namespace Decidim::ExtraUserFields

      routes do
        root to: "admin/insights#show"
        post "export", to: "admin/insights#export", as: :export
      end
    end
  end
end
