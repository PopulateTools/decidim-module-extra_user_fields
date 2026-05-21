# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe PivotTableBuilder do
    subject { described_class.new(participatory_space: participatory_process, metric_name: "participants", row_field: "gender", col_field: "age_span") }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }

    context "when there are no participants" do
      it "returns an empty pivot table" do
        result = subject.call
        expect(result).to be_empty
      end
    end

    context "when there are participants with extended data" do
      let(:user_female_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }
      let(:user_male_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "male", "date_of_birth" => 28.years.ago.to_date.to_s }) }
      let(:user_female_old) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 70.years.ago.to_date.to_s }) }
      let(:user_no_data) { create(:user, :confirmed, organization:, extended_data: {}) }

      before do
        create(:proposal, :published, component: proposal_component, users: [user_female_young])
        create(:proposal, :published, component: proposal_component, users: [user_male_young])
        create(:proposal, :published, component: proposal_component, users: [user_female_old])
        create(:proposal, :published, component: proposal_component, users: [user_no_data])
      end

      it "includes all configured gender values plus nil" do
        result = subject.call
        expect(result.row_values).to eq(%w(female male other) + [nil])
      end

      it "includes all configured insight_age_span values plus nil" do
        result = subject.call
        expect(result.col_values).to eq(%w(up_to_20 21_to_30 31_to_40 41_to_50 51_to_60 61_or_more) + [nil])
      end

      it "fills cells with correct counts" do
        result = subject.call
        expect(result.cell("female", "21_to_30")).to eq(1)
        expect(result.cell("male", "21_to_30")).to eq(1)
        expect(result.cell("female", "61_or_more")).to eq(1)
        expect(result.cell(nil, nil)).to eq(1)
      end

      it "shows zero for configured values with no data" do
        result = subject.call
        expect(result.cell("other", "21_to_30")).to eq(0)
        expect(result.cell("female", "up_to_20")).to eq(0)
        expect(result.cell("female", "31_to_40")).to eq(0)
      end

      it "calculates correct totals" do
        result = subject.call
        expect(result.grand_total).to eq(4)
        expect(result.row_total("female")).to eq(2)
        expect(result.col_total("21_to_30")).to eq(2)
      end
    end

    context "when users only have stored age_range (no date_of_birth)" do
      let(:user_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "17_to_30" }) }
      let(:user_old) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "age_range" => "61_or_more" }) }

      before do
        create(:proposal, :published, component: proposal_component, users: [user_young])
        create(:proposal, :published, component: proposal_component, users: [user_old])
      end

      it "treats them as not specified since stored age_range is ignored" do
        result = subject.call
        expect(result.cell("female", nil)).to eq(2)
      end

      it "still includes all configured insight_age_span values in order" do
        result = subject.call
        expect(result.col_values).to eq(%w(up_to_20 21_to_30 31_to_40 41_to_50 51_to_60 61_or_more) + [nil])
      end
    end

    context "when config uses symbols instead of strings" do
      let(:user_female) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }
      let(:user_male) { create(:user, :confirmed, organization:, extended_data: { "gender" => "male", "date_of_birth" => 35.years.ago.to_date.to_s }) }

      before do
        allow(Decidim::ExtraUserFields.config).to receive(:genders).and_return([:female, :male])
        create(:proposal, :published, component: proposal_component, users: [user_female])
        create(:proposal, :published, component: proposal_component, users: [user_male])
      end

      it "does not produce duplicate columns" do
        result = subject.call
        expect(result.row_values.count("female") + result.row_values.count(:female)).to eq(1)
        expect(result.row_values.count("male") + result.row_values.count(:male)).to eq(1)
      end

      it "counts users correctly in normalized columns" do
        result = subject.call
        expect(result.cell("female", "21_to_30")).to eq(1)
        expect(result.cell("male", "31_to_40")).to eq(1)
      end
    end

    context "with an invalid metric name" do
      subject { described_class.new(participatory_space: participatory_process, metric_name: "invalid", row_field: "gender", col_field: "age_span") }

      it "returns an empty pivot table" do
        result = subject.call
        expect(result).to be_empty
      end
    end
  end
end
