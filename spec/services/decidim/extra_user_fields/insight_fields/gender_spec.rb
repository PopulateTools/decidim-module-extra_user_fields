# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  module InsightFields
    describe Gender do
      subject { described_class.new }

      describe "#field_name" do
        it { expect(subject.field_name).to eq("gender") }
      end

      describe "#extract" do
        it "returns the gender value from extended_data" do
          expect(subject.extract({ "gender" => "female" })).to eq("female")
        end

        it "normalizes prefer_not_to_say to nil" do
          expect(subject.extract({ "gender" => "prefer_not_to_say" })).to be_nil
        end

        it "returns nil when gender is missing" do
          expect(subject.extract({})).to be_nil
        end
      end

      describe "#ordered_values" do
        it "returns configured genders without prefer_not_to_say" do
          expect(subject.ordered_values).to eq(%w(female male other))
          expect(subject.ordered_values).not_to include("prefer_not_to_say")
        end
      end

      describe "#value_label" do
        it "translates known gender values" do
          expect(subject.value_label("female")).to eq("Female")
          expect(subject.value_label("male")).to eq("Male")
          expect(subject.value_label("other")).to eq("Other")
        end

        it "falls back to humanized value for unknown genders" do
          expect(subject.value_label("nonbinary")).to eq("Nonbinary")
        end
      end
    end
  end
end
