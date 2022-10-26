# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe UpdateExtraUserFields do
        let(:organization) { create(:organization, extra_user_fields: {}) }
        let(:user) { create :user, :admin, :confirmed, organization: organization }

        let(:extra_user_fields_enabled) { true }
        let(:form_params) do
          {
            "enabled" => extra_user_fields_enabled
          }
        end
        let(:form) do
          ExtraUserFieldsForm.from_params(
            form_params
          ).with_context(
            current_user: user,
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }

        describe "call" do
          context "when the form is not valid" do
            before do
              expect(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't update the registration fields" do
              expect do
                command.call
                organization.reload
              end.not_to change(organization, :extra_user_fields)
            end
          end

          context "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "updates the organization registration fields" do
              command.call
              organization.reload

              expect(organization.extra_user_fields).to eq({ "enabled" => true })
            end
          end
        end
      end
    end
  end
end
