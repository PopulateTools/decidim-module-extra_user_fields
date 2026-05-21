# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  module InsightFields
    describe AgeSpan do
      subject { described_class.new }

      describe "#field_name" do
        it { expect(subject.field_name).to eq("age_span") }
      end

      describe "#extract" do
        it "computes age span from date_of_birth" do
          data = { "date_of_birth" => 25.years.ago.to_date.to_s }
          expect(subject.extract(data)).to eq("21_to_30")
        end

        it "returns nil when date_of_birth is missing" do
          expect(subject.extract({})).to be_nil
        end

        it "ignores the stored age_range field" do
          data = { "age_range" => "17_to_30" }
          expect(subject.extract(data)).to be_nil
        end
      end

      describe "#ordered_values" do
        it "returns configured insight age spans" do
          expect(subject.ordered_values).to eq(Decidim::ExtraUserFields.insight_age_spans)
        end
      end

      describe "#value_label" do
        it "translates known age span values" do
          expect(subject.value_label("21_to_30")).to eq("21 to 30")
          expect(subject.value_label("61_or_more")).to eq("More than 60")
          expect(subject.value_label("up_to_20")).to eq("Less than 20")
        end

        it "falls back to humanized value for unknown spans" do
          expect(subject.value_label("99_to_100")).to eq("99 to 100")
        end
      end
    end
  end
end
