# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Metrics
  describe BudgetVotesMetric do
    subject { described_class.new(participatory_process) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:budgets_component) { create(:budgets_component, :published, participatory_space: participatory_process) }
    let(:budget) { create(:budget, component: budgets_component) }
    let(:user1) { create(:user, :confirmed, organization:) }
    let(:user2) { create(:user, :confirmed, organization:) }

    context "when there are no budget votes" do
      it "returns an empty hash" do
        expect(subject.call).to eq({})
      end
    end

    context "when users have voted on budgets" do
      before do
        order1 = create(:order, :with_projects, budget:, user: user1)
        order1.update!(checked_out_at: Time.current)

        order2 = create(:order, :with_projects, budget:, user: user2)
        order2.update!(checked_out_at: Time.current)
      end

      it "returns the vote count per user" do
        result = subject.call
        expect(result[user1.id]).to eq(1)
        expect(result[user2.id]).to eq(1)
      end
    end

    context "when an order is not checked out" do
      before do
        create(:order, budget:, user: user1)
      end

      it "does not count it" do
        expect(subject.call).to eq({})
      end
    end

    context "when the component is unpublished" do
      let(:unpublished_component) { create(:budgets_component, :unpublished, participatory_space: participatory_process) }
      let(:unpublished_budget) { create(:budget, component: unpublished_component) }

      before do
        order = create(:order, :with_projects, budget: unpublished_budget, user: user1)
        order.update!(checked_out_at: Time.current)
      end

      it "does not count votes from unpublished components" do
        expect(subject.call).to eq({})
      end
    end

    context "when votes belong to another space" do
      let(:other_process) { create(:participatory_process, :with_steps, organization:) }
      let(:other_component) { create(:budgets_component, :published, participatory_space: other_process) }
      let(:other_budget) { create(:budget, component: other_component) }

      before do
        order = create(:order, :with_projects, budget: other_budget, user: user1)
        order.update!(checked_out_at: Time.current)
      end

      it "does not count them" do
        expect(subject.call).to eq({})
      end
    end
  end
end
