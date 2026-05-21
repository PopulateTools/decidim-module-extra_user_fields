# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Admin
  describe InsightsHelper do
    describe "#metric_label" do
      it "translates known metric names" do
        expect(helper.metric_label("participants")).to eq("Participants")
        expect(helper.metric_label("proposals_created")).to eq("Proposals created")
        expect(helper.metric_label("proposals_supported")).to eq("Proposals supported")
        expect(helper.metric_label("comments")).to eq("Comments")
        expect(helper.metric_label("budget_votes")).to eq("Budget votes")
      end

      it "humanizes unknown metric names" do
        expect(helper.metric_label("unknown_metric")).to eq("Unknown metric")
      end
    end

    describe "#field_label" do
      it "translates known field names" do
        expect(helper.field_label("gender")).to eq("Gender")
        expect(helper.field_label("age_span")).to eq("Age span")
        expect(helper.field_label("country")).to eq("Country")
      end

      it "humanizes unknown field names" do
        expect(helper.field_label("unknown_field")).to eq("Unknown field")
      end
    end

    describe "#field_value_label" do
      it "returns 'Not specified / Prefer not to say' for nil values" do
        expect(helper.field_value_label("gender", nil)).to eq("Not specified / Prefer not to say")
      end

      it "translates gender values via genders namespace" do
        expect(helper.field_value_label("gender", "female")).to eq("Female")
        expect(helper.field_value_label("gender", "male")).to eq("Male")
        expect(helper.field_value_label("gender", "other")).to eq("Other")
      end

      it "translates age_span values via insight_age_spans namespace" do
        expect(helper.field_value_label("age_span", "21_to_30")).to eq("21 to 30")
        expect(helper.field_value_label("age_span", "61_or_more")).to eq("More than 60")
        expect(helper.field_value_label("age_span", "up_to_20")).to eq("Less than 20")
      end

      it "falls back to humanized value for other fields" do
        expect(helper.field_value_label("custom_field", "some_place")).to eq("Some place")
      end

      it "translates country codes to country names" do
        expect(helper.field_value_label("country", "DE")).to eq("Germany")
      end

      it "falls back to humanized value for unknown country codes" do
        expect(helper.field_value_label("country", "unknown_code")).to eq("Unknown code")
      end
    end

    describe "#count_with_percentage" do
      it "returns count with percentage of total" do
        result = helper.count_with_percentage(31, 100)
        expect(result).to include("31")
        expect(result).to include("31%")
        expect(result).to include("insights-table__percentage")
      end

      it "strips insignificant zeros from percentage" do
        result = helper.count_with_percentage(50, 100)
        expect(result).to include("50%")
        expect(result).not_to include("50.0%")
      end

      it "shows one decimal place when needed" do
        result = helper.count_with_percentage(1, 3)
        expect(result).to include("33.3%")
      end

      it "returns plain count when total is zero" do
        result = helper.count_with_percentage(5, 0)
        expect(result).to eq("5")
      end

      it "shows 100% when value equals total" do
        result = helper.count_with_percentage(100, 100)
        expect(result).to include("100")
        expect(result).to include("100%")
        expect(result).to include("insights-table__percentage")
      end
    end

    describe "#insight_selector_field" do
      it "renders a selector with label and select tag" do
        result = helper.insight_selector_field(:rows, %w(gender age_span), "gender", &:humanize)

        expect(result).to include('class="insights-selectors__field"')
        expect(result).to include("<label")
        expect(result).to include('for="rows"')
        expect(result).to include("Rows (Y axis)")
        expect(result).to include("<select")
        expect(result).to include("Gender")
        expect(result).to include("Age span")
        expect(result).to include("onchange")
        expect(result).to include("requestSubmit()")
      end

      it "marks the selected option" do
        result = helper.insight_selector_field(:rows, %w(gender age_span), "age_span", &:humanize)

        expect(result).to include("selected")
      end
    end
  end
end
