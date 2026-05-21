# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Metrics
  describe ParticipantsMetric do
    subject { described_class.new(participatory_process) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user1) { create(:user, :confirmed, organization:) }
    let(:user2) { create(:user, :confirmed, organization:) }

    context "when there are no activities" do
      it "returns an empty hash" do
        expect(subject.call).to eq({})
      end
    end

    context "when users have created proposals" do
      before do
        create(:proposal, :published, component: proposal_component, users: [user1])
        create(:proposal, :published, component: proposal_component, users: [user2])
      end

      it "returns each user counted once" do
        result = subject.call
        expect(result[user1.id]).to eq(1)
        expect(result[user2.id]).to eq(1)
      end
    end

    context "when a user has multiple activities" do
      let!(:proposal) { create(:proposal, :published, component: proposal_component, users: [user1]) }

      before do
        create(:comment, commentable: proposal, author: user1)
      end

      it "still counts the user only once" do
        result = subject.call
        expect(result[user1.id]).to eq(1)
      end
    end

    context "when users supported proposals" do
      let!(:proposal) { create(:proposal, :published, component: proposal_component, users: [user1]) }

      before do
        create(:proposal_vote, proposal: proposal, author: user2)
      end

      it "includes the supporter" do
        result = subject.call
        expect(result[user2.id]).to eq(1)
      end

      it "does not double-count a user who also authored" do
        create(:proposal_vote, proposal: proposal, author: user1)
        result = subject.call
        expect(result[user1.id]).to eq(1)
      end
    end

    context "when users voted on budgets" do
      let(:budgets_component) { create(:budgets_component, :published, participatory_space: participatory_process) }
      let(:budget) { create(:budget, component: budgets_component) }

      before do
        order = create(:order, :with_projects, budget:, user: user1)
        order.update!(checked_out_at: Time.current)
      end

      it "includes the voter" do
        result = subject.call
        expect(result[user1.id]).to eq(1)
      end
    end

    context "when users commented on proposals" do
      let!(:proposal) { create(:proposal, :published, component: proposal_component, users: [user1]) }

      before do
        create(:comment, commentable: proposal, author: user2)
      end

      it "includes the commenter" do
        result = subject.call
        expect(result).to have_key(user2.id)
      end
    end

    context "when proposals are hidden" do
      before do
        create(:proposal, :published, :hidden, component: proposal_component, users: [user1])
      end

      it "does not count the author" do
        expect(subject.call).to eq({})
      end
    end

    context "when the component is unpublished" do
      let(:unpublished_component) { create(:proposal_component, :unpublished, participatory_space: participatory_process) }

      before do
        create(:proposal, :published, component: unpublished_component, users: [user1])
      end

      it "does not count participants from unpublished components" do
        expect(subject.call).to eq({})
      end
    end

    context "when activities belong to another space" do
      let(:other_process) { create(:participatory_process, :with_steps, organization:) }
      let(:other_component) { create(:proposal_component, :published, participatory_space: other_process) }

      before do
        create(:proposal, :published, component: other_component, users: [user1])
      end

      it "does not count them" do
        expect(subject.call).to eq({})
      end
    end
  end
end
