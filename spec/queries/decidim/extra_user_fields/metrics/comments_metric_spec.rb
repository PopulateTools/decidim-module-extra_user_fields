# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Metrics
  describe CommentsMetric do
    subject { described_class.new(participatory_process) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user1) { create(:user, :confirmed, organization:) }
    let(:user2) { create(:user, :confirmed, organization:) }

    context "when there are no comments" do
      it "returns an empty hash" do
        expect(subject.call).to eq({})
      end
    end

    context "when users have commented on proposals" do
      let!(:proposal) { create(:proposal, :published, component: proposal_component, users: [user1]) }

      before do
        create_list(:comment, 3, commentable: proposal, author: user1)
        create(:comment, commentable: proposal, author: user2)
      end

      it "returns the comment count per user" do
        result = subject.call
        expect(result[user1.id]).to eq(3)
        expect(result[user2.id]).to eq(1)
      end
    end

    context "when users have commented on budget projects" do
      let(:budgets_component) { create(:budgets_component, :published, participatory_space: participatory_process) }
      let(:budget) { create(:budget, component: budgets_component) }
      let!(:project) { create(:project, budget:) }

      before do
        create_list(:comment, 2, commentable: project, author: user1)
      end

      it "returns the comment count per user" do
        result = subject.call
        expect(result[user1.id]).to eq(2)
      end
    end

    context "when comments span both proposals and budget projects" do
      let!(:proposal) { create(:proposal, :published, component: proposal_component, users: [user1]) }
      let(:budgets_component) { create(:budgets_component, :published, participatory_space: participatory_process) }
      let(:budget) { create(:budget, component: budgets_component) }
      let!(:project) { create(:project, budget:) }

      before do
        create(:comment, commentable: proposal, author: user1)
        create(:comment, commentable: project, author: user1)
      end

      it "sums comments across resource types" do
        expect(subject.call[user1.id]).to eq(2)
      end
    end

    context "when proposals are hidden" do
      let!(:proposal) { create(:proposal, :published, :hidden, component: proposal_component, users: [user1]) }

      before do
        create(:comment, commentable: proposal, author: user1)
      end

      it "still counts comments (user participated in the space)" do
        expect(subject.call[user1.id]).to eq(1)
      end
    end

    context "when the component is unpublished" do
      let(:unpublished_component) { create(:proposal_component, :unpublished, participatory_space: participatory_process) }
      let!(:proposal) { create(:proposal, :published, component: unpublished_component, users: [user1]) }

      before do
        create(:comment, commentable: proposal, author: user1)
      end

      it "still counts comments (user participated in the space)" do
        expect(subject.call[user1.id]).to eq(1)
      end
    end

    context "when comments belong to another space" do
      let(:other_process) { create(:participatory_process, :with_steps, organization:) }
      let(:other_component) { create(:proposal_component, :published, participatory_space: other_process) }
      let!(:proposal) { create(:proposal, :published, component: other_component, users: [user1]) }

      before do
        create(:comment, commentable: proposal, author: user1)
      end

      it "does not count them" do
        expect(subject.call).to eq({})
      end
    end
  end
end
