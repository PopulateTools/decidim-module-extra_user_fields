# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Admin
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { create(:organization) }
    let(:context) { { current_organization: organization } }
    let(:action) { { scope: :admin, action: :read, subject: :extra_user_fields } }
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    context "when user is admin" do
      let(:user) { create(:user, :admin, organization:) }

      it { is_expected.to be_truthy }

      context "when scope is not admin" do
        let(:action) { { scope: :foo, action: :read, subject: :extra_user_fields } }

        it_behaves_like "permission is not set"
      end

      context "when reading insights" do
        let(:action) { { scope: :admin, action: :read, subject: :insights } }

        it { is_expected.to be_truthy }
      end
    end

    context "when user is not admin" do
      let(:user) { create(:user, organization:) }

      context "and tries to read extra user fields" do
        let(:action) { { scope: :admin, action: :read, subject: :extra_user_fields } }

        it_behaves_like "permission is not set"
      end

      context "and tries to update extra user fields" do
        let(:action) { { scope: :admin, action: :update, subject: :extra_user_fields } }

        it_behaves_like "permission is not set"
      end

      context "and tries to read insights" do
        let(:action) { { scope: :admin, action: :read, subject: :insights } }

        it_behaves_like "permission is not set"
      end
    end
  end
end
