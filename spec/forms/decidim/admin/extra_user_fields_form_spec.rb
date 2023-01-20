# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe ExtraUserFieldsForm do
        subject do
          described_class.from_params(
            attributes
          ).with_context(
            context
          )
        end

        let(:organization) { create(:organization) }
        let(:extra_user_fields) { true }

        let(:attributes) do
          {
            extra_user_fields: extra_user_fields
          }
        end

        let(:context) do
          {
            current_organization: organization
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
