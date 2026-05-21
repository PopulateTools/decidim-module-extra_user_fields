# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      # Base class for insight metrics. Each subclass returns { user_id => count }
      # and includes only the query concerns it needs.
      class BaseMetric
        def initialize(participatory_space)
          @participatory_space = participatory_space
        end

        # @return [Hash{Integer => Integer}] user_id => count
        def call
          raise NotImplementedError, "#{self.class}#call must be implemented"
        end

        private

        attr_reader :participatory_space

        def component_ids_for(manifest_name)
          participatory_space.components.where(manifest_name: manifest_name).published.pluck(:id)
        end
      end
    end
  end
end
