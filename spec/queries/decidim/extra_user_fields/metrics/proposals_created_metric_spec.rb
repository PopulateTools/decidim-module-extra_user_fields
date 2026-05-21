# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Metrics
  describe ProposalsCreatedMetric do
    subject { described_class.new(participatory_process) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user1) { create(:user, :confirmed, organization:) }
    let(:user2) { create(:user, :confirmed, organization:) }

    context "when there are no proposals" do
      it "returns an empty hash" do
        expect(subject.call).to eq({})
      end
    end

    context "when users have created proposals" do
      before do
        create_list(:proposal, 3, :published, component: proposal_component, users: [user1])
        create(:proposal, :published, component: proposal_component, users: [user2])
      end

      it "returns the count per user" do
        result = subject.call
        expect(result[user1.id]).to eq(3)
        expect(result[user2.id]).to eq(1)
      end
    end

    context "when proposals belong to another space" do
      let(:other_process) { create(:participatory_process, :with_steps, organization:) }
      let(:other_component) { create(:proposal_component, :published, participatory_space: other_process) }

      before do
        create(:proposal, :published, component: other_component, users: [user1])
      end

      it "does not count them" do
        expect(subject.call).to eq({})
      end
    end

    context "when proposals are hidden" do
      before do
        create(:proposal, :published, :hidden, component: proposal_component, users: [user1])
      end

      it "does not count them" do
        expect(subject.call).to eq({})
      end
    end

    context "when the component is unpublished" do
      let(:unpublished_component) { create(:proposal_component, :unpublished, participatory_space: participatory_process) }

      before do
        create(:proposal, :published, component: unpublished_component, users: [user1])
      end

      it "does not count proposals from unpublished components" do
        expect(subject.call).to eq({})
      end
    end
  end
end
