# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe InsightFields do
    describe ".for" do
      it "resolves gender to Gender class" do
        expect(described_class.for("gender")).to be_a(InsightFields::Gender)
      end

      it "resolves age_span to AgeSpan class" do
        expect(described_class.for("age_span")).to be_a(InsightFields::AgeSpan)
      end

      it "resolves country to Country class" do
        expect(described_class.for("country")).to be_a(InsightFields::Country)
      end

      it "falls back to Base for unknown fields" do
        field = described_class.for("unknown_field")
        expect(field).to be_a(InsightFields::Base)
        expect(field.field_name).to eq("unknown_field")
      end
    end
  end
end
