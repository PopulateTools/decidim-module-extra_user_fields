# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe InsightMetrics do
    describe ".available_metrics" do
      it "returns all metric names" do
        expect(described_class.available_metrics).to contain_exactly(
          "participants",
          "proposals_created",
          "proposals_supported",
          "comments",
          "budget_votes"
        )
      end
    end

    describe ".metric_class" do
      it "returns the correct class for each metric" do
        expect(described_class.metric_class("participants")).to eq(Metrics::ParticipantsMetric)
        expect(described_class.metric_class("proposals_created")).to eq(Metrics::ProposalsCreatedMetric)
        expect(described_class.metric_class("proposals_supported")).to eq(Metrics::ProposalsSupportedMetric)
        expect(described_class.metric_class("comments")).to eq(Metrics::CommentsMetric)
        expect(described_class.metric_class("budget_votes")).to eq(Metrics::BudgetVotesMetric)
      end

      it "returns nil for unknown metrics" do
        expect(described_class.metric_class("unknown")).to be_nil
      end
    end

    describe ".valid_metric?" do
      it "returns true for valid metrics" do
        expect(described_class.valid_metric?("participants")).to be(true)
      end

      it "returns false for invalid metrics" do
        expect(described_class.valid_metric?("unknown")).to be(false)
      end
    end
  end
end
