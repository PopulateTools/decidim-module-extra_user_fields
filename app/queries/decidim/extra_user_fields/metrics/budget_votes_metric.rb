# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Counts checked-out budget orders (votes) by each user within the participatory space.
      class BudgetVotesMetric < BaseMetric
        include Concerns::BudgetQueries

        def call
          return {} unless has_budgets?

          budget_orders_scope.group(:decidim_user_id).count
        end
      end
    end
  end
end
