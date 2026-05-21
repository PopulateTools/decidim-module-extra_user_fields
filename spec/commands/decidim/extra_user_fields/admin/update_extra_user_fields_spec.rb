# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe UpdateExtraUserFields do
        let(:organization) { create(:organization, extra_user_fields: {}) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }

        let(:phone_number_pattern) { "^(\\+34)?[0-9 ]{9,12}$" }
        let(:phone_number_placeholder) { "+34999888777" }

        let(:form_params) do
          {
            "enabled" => true,
            "country_enabled" => true,
            "country_required" => true,
            "gender_enabled" => true,
            "gender_required" => false,
            "age_range_enabled" => true,
            "age_range_required" => false,
            "date_of_birth_enabled" => true,
            "date_of_birth_required" => true,
            "postal_code_enabled" => true,
            "postal_code_required" => false,
            "phone_number_enabled" => true,
            "phone_number_required" => false,
            "phone_number_pattern" => phone_number_pattern,
            "phone_number_placeholder_en" => phone_number_placeholder,
            "location_enabled" => false,
            "location_required" => false,
            "underage_enabled" => true,
            "underage_required" => false,
            "underage_limit" => 18,
            "select_fields" => {
              "participant_type" => { "enabled" => "true", "required" => "false" },
              "non_existing_field" => { "enabled" => "true", "required" => "false" }
            },
            "boolean_fields" => {
              "ngo" => { "enabled" => "true", "required" => "false" },
              "non_existing_field" => { "enabled" => "true", "required" => "false" }
            },
            "text_fields" => {
              "motto" => { "enabled" => "true", "required" => "false" },
              "non_existing_field" => { "enabled" => "true", "required" => "false" }
            }
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
              expect(extra_user_fields).to include("country" => { "enabled" => true, "required" => true })
              expect(extra_user_fields).to include("date_of_birth" => { "enabled" => true, "required" => true })
              expect(extra_user_fields).to include("postal_code" => { "enabled" => true, "required" => false })
              expect(extra_user_fields).to include("gender" => { "enabled" => true, "required" => false })
              expect(extra_user_fields).to include("age_range" => { "enabled" => true, "required" => false })
              phone = extra_user_fields["phone_number"]
              expect(phone).to include("enabled" => true, "required" => false, "pattern" => phone_number_pattern)
              expect(phone["placeholder"]).to include("en" => phone_number_placeholder)
              expect(extra_user_fields).to include("location" => { "enabled" => false, "required" => false })
              expect(extra_user_fields).to include("underage" => { "enabled" => true, "required" => false, "limit" => 18 })
              expect(extra_user_fields["select_fields"]).to include("participant_type" => { "enabled" => true, "required" => false })
              expect(extra_user_fields["boolean_fields"]).to include("ngo" => { "enabled" => true, "required" => false })
              expect(extra_user_fields["text_fields"]).to include("motto" => { "enabled" => true, "required" => false })
              expect(extra_user_fields).not_to have_key("underage_limit")
            end
          end
        end
      end
    end
  end
end
