# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe HeatmapIntensity do
    # Wrapper to expose private methods for testing
    let(:wrapper) do
      Class.new do
        include HeatmapIntensity
        public :intensity_vars, :total_intensity_vars
      end.new
    end

    describe "#intensity_vars" do
      it "returns empty string when value is zero" do
        expect(wrapper.intensity_vars(0, 1, 10)).to eq("")
      end

      it "returns empty string when max is zero" do
        expect(wrapper.intensity_vars(5, 0, 0)).to eq("")
      end

      it "returns zero intensity when min equals max" do
        result = wrapper.intensity_vars(5, 5, 5)
        expect(result).to include("--i:0.0")
        expect(result).to include("--tc:#1a1a1a")
      end

      it "returns zero intensity when value equals min" do
        result = wrapper.intensity_vars(2, 2, 10)
        expect(result).to include("--i:0.0")
        expect(result).to include("--tc:#1a1a1a")
      end

      it "returns full intensity when value equals max" do
        result = wrapper.intensity_vars(10, 2, 10)
        expect(result).to include("--i:1.0")
        expect(result).to include("--tc:#fff")
      end

      it "returns proportional intensity for mid-range values" do
        result = wrapper.intensity_vars(6, 2, 10)
        expect(result).to include("--i:0.5")
        expect(result).to include("--tc:#1a1a1a")
      end

      it "uses white text color when intensity is above 0.6" do
        # intensity = (8 - 0) / (10 - 0) = 0.8
        result = wrapper.intensity_vars(8, 0, 10)
        expect(result).to include("--tc:#fff")
      end

      it "uses dark text color when intensity is exactly 0.6" do
        # intensity = (6 - 0) / (10 - 0) = 0.6 — exactly 0.6 is NOT > 0.6
        result = wrapper.intensity_vars(6, 0, 10)
        expect(result).to include("--tc:#1a1a1a")
      end

      it "uses white text color when intensity exceeds 0.6" do
        # intensity = (7 - 0) / (10 - 0) = 0.7
        result = wrapper.intensity_vars(7, 0, 10)
        expect(result).to include("--tc:#fff")
      end

      it "rounds intensity to 3 decimal places" do
        # intensity = (1 - 0) / (3 - 0) = 0.333...
        result = wrapper.intensity_vars(1, 0, 3)
        expect(result).to include("--i:0.333")
      end
    end

    describe "#total_intensity_vars" do
      it "returns empty string when value is zero" do
        expect(wrapper.total_intensity_vars(0, 10)).to eq("")
      end

      it "returns empty string when max is zero" do
        expect(wrapper.total_intensity_vars(5, 0)).to eq("")
      end

      it "returns full intensity when value equals max" do
        result = wrapper.total_intensity_vars(10, 10)
        expect(result).to include("--i:1.0")
        expect(result).to include("--tc:#fff")
      end

      it "returns proportional intensity" do
        result = wrapper.total_intensity_vars(5, 10)
        expect(result).to include("--i:0.5")
        expect(result).to include("--tc:#1a1a1a")
      end
    end
  end
end
