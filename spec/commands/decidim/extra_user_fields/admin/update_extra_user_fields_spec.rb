# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe UpdateExtraUserFields do
        let(:organization) { create(:organization, extra_user_fields: {}) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }

        let(:extra_user_fields_enabled) { true }
        let(:postal_code) { true }
        let(:country) { true }
        let(:gender) { true }
        let(:date_of_birth) { true }
        let(:phone_number) { true }
        let(:phone_number_pattern) { "^(\\+34)?[0-9 ]{9,12}$" }
        let(:phone_number_placeholder) { "+34999888777" }
        let(:location) { true }
        let(:underage) { true }
        let(:underage_limit) { 18 }
        # Block ExtraUserFields RspecVar

        # EndBlock

        # rubocop:disable Style/TrailingCommaInHashLiteral
        let(:form_params) do
          {
            "enabled" => extra_user_fields_enabled,
            "postal_code" => postal_code,
            "country" => country,
            "gender" => gender,
            "date_of_birth" => date_of_birth,
            "phone_number" => phone_number,
            "phone_number_pattern" => phone_number_pattern,
            "phone_number_placeholder" => phone_number_placeholder,
            "location" => location,
            "underage" => underage,
            "underage_limit" => underage_limit,
            # Block ExtraUserFields ExtraUserFields

            # EndBlock
          }
        end
        # rubocop:enable Style/TrailingCommaInHashLiteral

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
              allow(form).to receive(:invalid?).and_return(true)
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

              extra_user_fields = organization.extra_user_fields
              expect(extra_user_fields).to include("enabled" => true)
              expect(extra_user_fields).to include("country" => { "enabled" => true })
              expect(extra_user_fields).to include("date_of_birth" => { "enabled" => true })
              expect(extra_user_fields).to include("gender" => { "enabled" => true })
              expect(extra_user_fields).to include("country" => { "enabled" => true })
              expect(extra_user_fields).to include("phone_number" => { "enabled" => true, "pattern" => phone_number_pattern, "placeholder" => phone_number_placeholder })
              expect(extra_user_fields).to include("location" => { "enabled" => true })
              expect(extra_user_fields).to include("underage" => { "enabled" => true })
              expect(extra_user_fields).to include("underage_limit" => 18)
              # Block ExtraUserFields InclusionSpec

              # EndBlock
            end
          end
        end
      end
    end
  end
end
