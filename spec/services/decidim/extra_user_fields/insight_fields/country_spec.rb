# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  module InsightFields
    describe Country do
      subject { described_class.new }

      describe "#field_name" do
        it { expect(subject.field_name).to eq("country") }
      end

      describe "#extract" do
        it "returns the country value from extended_data" do
          expect(subject.extract({ "country" => "france" })).to eq("france")
        end

        it "returns nil for blank values" do
          expect(subject.extract({})).to be_nil
        end
      end

      describe "#ordered_values" do
        it "returns nil (no predefined order)" do
          expect(subject.ordered_values).to be_nil
        end
      end

      describe "#value_label" do
        it "translates country codes to country names" do
          expect(subject.value_label("DE")).to eq("Germany")
          expect(subject.value_label("FR")).to eq("France")
        end

        it "falls back to humanized value for unknown codes" do
          expect(subject.value_label("unknown_code")).to eq("Unknown code")
        end
      end
    end
  end
end
