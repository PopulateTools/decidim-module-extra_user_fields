# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts proposals created by each user within the participatory space.
      class ProposalsCreatedMetric < BaseMetric
        include Concerns::ProposalQueries

        def call
          return {} unless has_proposals?

          coauthorships_scope.group(:decidim_author_id).count
        end
      end
    end
  end
end
