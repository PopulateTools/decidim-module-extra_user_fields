# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # Shared heatmap normalization logic for pivot table presenters.
    # Outputs CSS custom properties consumed by SCSS:
    #   --i  = intensity (0.0–1.0), drives the color gradient
    #   --tc = text color (#fff or #1a1a1a), ensures contrast on colored backgrounds
    module HeatmapIntensity
      private

      def intensity_vars(value, min, max)
        return "" if value.zero? || max.zero?

        range = max - min
        intensity = range.zero? ? 0.0 : (value - min).to_f / range
        text_color = intensity > 0.6 ? "#fff" : "#1a1a1a"

        "--i:#{intensity.round(3)};--tc:#{text_color};"
      end

      def total_intensity_vars(value, max)
        return "" if value.zero? || max.zero?

        intensity = (value.to_f / max).round(3)
        text_color = intensity > 0.6 ? "#fff" : "#1a1a1a"

        "--i:#{intensity};--tc:#{text_color};"
      end
    end
  end
end
