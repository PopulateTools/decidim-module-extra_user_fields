# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      module Concerns
        # Scopes for budgets and checked-out budget orders.
        module BudgetQueries
          extend ActiveSupport::Concern

          private

          def has_budgets?
            component_ids_for("budgets").any?
          end

          def budget_ids
            Decidim::Budgets::Budget
              .where(decidim_component_id: component_ids_for("budgets"))
              .select(:id)
          end

          def budget_orders_scope
            Decidim::Budgets::Order
              .where(decidim_budgets_budget_id: budget_ids)
              .where.not(checked_out_at: nil)
          end
        end
      end
    end
  end
end
