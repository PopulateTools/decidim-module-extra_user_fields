# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts comments made by each user on resources within the participatory space.
      class CommentsMetric < BaseMetric
        include Concerns::CommentQueries

        def call
          comments_scope
            .where(decidim_author_type: "Decidim::UserBaseEntity")
            .group(:decidim_author_id)
            .count
        end
      end
    end
  end
end
