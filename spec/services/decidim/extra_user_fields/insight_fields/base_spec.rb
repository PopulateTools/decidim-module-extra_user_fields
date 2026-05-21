# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  module InsightFields
    describe Base do
      subject { described_class.new("custom_field") }

      describe "#extract" do
        it "returns the value from extended_data" do
          expect(subject.extract({ "custom_field" => "some_value" })).to eq("some_value")
        end

        it "returns nil for blank values" do
          expect(subject.extract({ "custom_field" => "" })).to be_nil
          expect(subject.extract({ "custom_field" => nil })).to be_nil
          expect(subject.extract({})).to be_nil
        end

        it "normalizes prefer_not_to_say to nil" do
          expect(subject.extract({ "custom_field" => "prefer_not_to_say" })).to be_nil
        end
      end

      describe "#ordered_values" do
        it "returns nil by default" do
          expect(subject.ordered_values).to be_nil
        end
      end

      describe "#value_label" do
        it "falls back to humanized value" do
          expect(subject.value_label("some_value")).to eq("Some value")
        end
      end
    end
  end
end
