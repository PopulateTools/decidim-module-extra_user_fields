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
            extra_user_fields:
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

        describe "validation" do
          context "when a profile field enabled is true" do
            let(:attributes) { { country_enabled: true, country_required: true } }

            it { is_expected.to be_valid }
          end

          context "when a profile field is enabled but not required" do
            let(:attributes) { { country_enabled: true, country_required: false } }

            it { is_expected.to be_valid }
          end

          context "when a profile field is disabled" do
            let(:attributes) { { country_enabled: false, country_required: false } }

            it { is_expected.to be_valid }
          end
        end

        describe "#map_model" do
          let(:org_extra_user_fields) do
            {
              "enabled" => true,
              "country" => { "enabled" => true, "required" => true },
              "postal_code" => { "enabled" => true, "required" => false },
              "gender" => { "enabled" => false, "required" => false },
              "date_of_birth" => { "enabled" => false, "required" => false },
              "age_range" => { "enabled" => false, "required" => false },
              "phone_number" => { "enabled" => true, "required" => false, "pattern" => "^\\+33", "placeholder" => { "en" => "+33..." } },
              "location" => { "enabled" => false, "required" => false },
              "underage" => { "enabled" => true, "required" => false, "limit" => 16 },
              "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } },
              "boolean_fields" => { "ngo" => { "enabled" => true, "required" => false } },
              "text_fields" => { "motto" => { "enabled" => true, "required" => false } }
            }
          end
          let(:model) { build(:organization, extra_user_fields: org_extra_user_fields) }

          before { subject.map_model(model) }

          it "loads standard field states" do
            expect(subject.country_enabled).to be true
            expect(subject.country_required).to be true
            expect(subject.postal_code_enabled).to be true
            expect(subject.postal_code_required).to be false
            expect(subject.gender_enabled).to be false
            expect(subject.gender_required).to be false
          end

          it "loads phone_number config" do
            expect(subject.phone_number_enabled).to be true
            expect(subject.phone_number_required).to be false
            expect(subject.phone_number_pattern).to eq("^\\+33")
            expect(subject.phone_number_placeholder).to eq({ "en" => "+33..." })
          end

          it "loads underage config" do
            expect(subject.underage_enabled).to be true
            expect(subject.underage_required).to be false
            expect(subject.underage_limit).to eq(16)
          end

          it "loads collection fields" do
            select_result = subject.select_fields
            expect(select_result[:participant_type] || select_result["participant_type"]).to eq({ "enabled" => true, "required" => true })
            boolean_result = subject.boolean_fields
            expect(boolean_result[:ngo] || boolean_result["ngo"]).to eq({ "enabled" => true, "required" => false })
            text_result = subject.text_fields
            expect(text_result[:motto] || text_result["motto"]).to eq({ "enabled" => true, "required" => false })
          end

          context "with nil/missing standard field" do
            let(:org_extra_user_fields) { { "enabled" => true } }

            it "normalizes to disabled" do
              expect(subject.country_enabled).to be false
              expect(subject.country_required).to be false
              expect(subject.gender_enabled).to be false
              expect(subject.gender_required).to be false
            end
          end

          context "with missing underage_limit" do
            let(:org_extra_user_fields) { { "enabled" => true, "underage" => { "enabled" => false, "required" => false } } }

            it "falls back to default" do
              expect(subject.underage_limit).to eq(Decidim::ExtraUserFields.underage_limit)
            end
          end
        end

        describe "#map_model collection field filtering" do
          let(:model) { build(:organization, extra_user_fields: org_fields) }

          before { subject.map_model(model) }

          context "when select_fields contain invalid keys" do
            let(:org_fields) do
              {
                "enabled" => true,
                "select_fields" => {
                  "participant_type" => { "enabled" => true, "required" => true },
                  "bogus" => { "enabled" => true, "required" => false }
                }
              }
            end

            it "filters invalid keys and keeps valid ones" do
              result = subject.select_fields
              pt = result["participant_type"] || result[:participant_type]
              expect(pt).to be_present
              expect(pt["enabled"]).to be true
              expect(pt["required"]).to be true
              expect(result.keys.map(&:to_s)).not_to include("bogus")
            end
          end

          context "when select_fields contain non-hash values" do
            let(:org_fields) do
              { "enabled" => true, "select_fields" => { "participant_type" => "foobar" } }
            end

            it "normalizes entries with invalid values to disabled state" do
              result = subject.select_fields
              pt = result["participant_type"] || result[:participant_type]
              expect(pt).to eq({ "enabled" => false, "required" => false })
            end
          end

          context "when boolean_fields contain invalid keys" do
            let(:org_fields) do
              {
                "enabled" => true,
                "boolean_fields" => {
                  "ngo" => { "enabled" => true, "required" => false },
                  "bogus" => { "enabled" => true, "required" => false }
                }
              }
            end

            it "filters invalid entries" do
              result = subject.boolean_fields
              expect(result.keys.map(&:to_s)).to include("ngo")
              expect(result.keys.map(&:to_s)).not_to include("bogus")
            end
          end

          context "when text_fields contain invalid keys" do
            let(:org_fields) do
              {
                "enabled" => true,
                "text_fields" => {
                  "motto" => { "enabled" => true, "required" => false },
                  "bogus" => { "enabled" => true, "required" => true }
                }
              }
            end

            it "filters invalid keys and keeps valid ones" do
              result = subject.text_fields
              motto = result["motto"] || result[:motto]
              expect(motto).to be_present
              expect(motto["enabled"]).to be true
              expect(motto["required"]).to be false
              expect(result.keys.map(&:to_s)).not_to include("bogus")
            end
          end
        end

        describe "collection fields from params" do
          context "with nil select_fields" do
            let(:attributes) { { select_fields: nil } }

            it "returns empty hash" do
              expect(subject.select_fields).to eq({})
            end
          end

          context "with nil boolean_fields" do
            let(:attributes) { { boolean_fields: nil } }

            it "returns empty hash" do
              expect(subject.boolean_fields).to eq({})
            end
          end

          context "with nil text_fields" do
            let(:attributes) { { text_fields: nil } }

            it "returns empty hash" do
              expect(subject.text_fields).to eq({})
            end
          end
        end
      end
    end
  end
end
