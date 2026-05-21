# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Metrics
  describe ProposalsSupportedMetric do
    subject { described_class.new(participatory_process) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user1) { create(:user, :confirmed, organization:) }
    let(:user2) { create(:user, :confirmed, organization:) }

    context "when there are no votes" do
      it "returns an empty hash" do
        expect(subject.call).to eq({})
      end
    end

    context "when users have supported proposals" do
      let!(:proposal1) { create(:proposal, :published, component: proposal_component, users: [user1]) }
      let!(:proposal2) { create(:proposal, :published, component: proposal_component, users: [user1]) }

      before do
        create(:proposal_vote, proposal: proposal1, author: user2)
        create(:proposal_vote, proposal: proposal2, author: user2)
        create(:proposal_vote, proposal: proposal1, author: user1)
      end

      it "returns the vote count per user" do
        result = subject.call
        expect(result[user2.id]).to eq(2)
        expect(result[user1.id]).to eq(1)
      end
    end

    context "when the proposal is hidden" do
      let!(:proposal) { create(:proposal, :published, :hidden, component: proposal_component, users: [user1]) }

      before do
        create(:proposal_vote, proposal: proposal, author: user2)
      end

      it "does not count votes on hidden proposals" do
        expect(subject.call).to eq({})
      end
    end

    context "when the component is unpublished" do
      let(:unpublished_component) { create(:proposal_component, :unpublished, participatory_space: participatory_process) }
      let!(:proposal) { create(:proposal, :published, component: unpublished_component, users: [user1]) }

      before do
        create(:proposal_vote, proposal: proposal, author: user2)
      end

      it "does not count votes from unpublished components" do
        expect(subject.call).to eq({})
      end
    end

    context "when votes belong to another space" do
      let(:other_process) { create(:participatory_process, :with_steps, organization:) }
      let(:other_component) { create(:proposal_component, :published, participatory_space: other_process) }
      let!(:proposal) { create(:proposal, :published, component: other_component, users: [user1]) }

      before do
        create(:proposal_vote, proposal: proposal, author: user2)
      end

      it "does not count them" do
        expect(subject.call).to eq({})
      end
    end
  end
end
