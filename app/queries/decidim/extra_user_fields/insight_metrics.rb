# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Registry of available insight metrics.
    # Resolves metric names to their implementation classes.
    module InsightMetrics
      def self.available_metrics
        Decidim::ExtraUserFields.insight_metrics.keys
      end

      def self.metric_class(name)
        class_name = Decidim::ExtraUserFields.insight_metrics[name.to_s]
        return unless class_name

        class_name.constantize
      end

      def self.valid_metric?(name)
        Decidim::ExtraUserFields.insight_metrics.has_key?(name.to_s)
      end
    end
  end
end
