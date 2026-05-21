# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts unique participants — users who have any activity in the participatory space.
      # Includes: proposal authors, proposal supporters, commenters, budget voters.
      # Each user is counted once regardless of how many activities they have.
      # Uses a SQL UNION to deduplicate on the database side.
      class ParticipantsMetric < BaseMetric
        include Concerns::ProposalQueries
        include Concerns::BudgetQueries
        include Concerns::CommentQueries

        def call
          participant_user_ids.index_with { 1 }
        end

        private

        def participant_user_ids
          unions = union_queries
          sql = "SELECT DISTINCT user_id FROM (#{unions.join(" UNION ALL ")}) AS participants"
          ActiveRecord::Base.connection.select_values(sql).map(&:to_i)
        end

        def union_queries
          queries = []
          queries.concat(proposal_author_queries) if has_proposals?
          queries << comment_author_query
          queries << budget_voter_query if has_budgets?
          queries
        end

        def proposal_author_queries
          [
            coauthorships_scope.select("decidim_author_id AS user_id").to_sql,
            proposal_votes_scope.select("decidim_author_id AS user_id").to_sql
          ]
        end

        def comment_author_query
          comments_scope
            .where(decidim_author_type: "Decidim::UserBaseEntity")
            .select("decidim_author_id AS user_id").to_sql
        end

        def budget_voter_query
          budget_orders_scope.select("decidim_user_id AS user_id").to_sql
        end
      end
    end
  end
end
