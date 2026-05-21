# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    describe ApplicationHelper do
      let(:organization) { create(:organization, extra_user_fields: org_extra_user_fields) }
      let(:org_extra_user_fields) do
        {
          "enabled" => true,
          "phone_number" => { "enabled" => true, "required" => false, "pattern" => "^\\+33", "placeholder" => "+33..." },
          "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } },
          "boolean_fields" => { "ngo" => { "enabled" => true, "required" => false } },
          "text_fields" => { "motto" => { "enabled" => true, "required" => false } }
        }
      end

      let(:helper_class) do
        Class.new do
          include Decidim::ExtraUserFields::ApplicationHelper

          attr_accessor :current_organization
        end
      end
      let(:helper) do
        h = helper_class.new
        h.current_organization = organization
        h
      end

      describe "#gender_options_for_select" do
        it "returns array of [gender, translation] pairs" do
          result = helper.gender_options_for_select
          expect(result).to be_an(Array)
          expect(result.first).to eq(%w(female Female))
          expect(result.map(&:first)).to match_array(Decidim::ExtraUserFields.genders)
        end
      end

      describe "#age_range_options_for_select" do
        it "returns array of [age_range, translation] pairs" do
          result = helper.age_range_options_for_select
          expect(result).to be_an(Array)
          expect(result.map(&:first)).to match_array(Decidim::ExtraUserFields.age_ranges)
        end
      end

      describe "#phone_number_extra_user_field_pattern" do
        it "returns pattern from org config" do
          expect(helper.phone_number_extra_user_field_pattern).to eq("^\\+33")
        end

        context "when no pattern is configured" do
          let(:org_extra_user_fields) { { "enabled" => true, "phone_number" => { "enabled" => true, "required" => false } } }

          it "returns nil" do
            expect(helper.phone_number_extra_user_field_pattern).to be_nil
          end
        end
      end

      describe "#phone_number_extra_user_field_placeholder" do
        it "returns placeholder from org config" do
          expect(helper.phone_number_extra_user_field_placeholder).to eq("+33...")
        end
      end

      describe "#custom_select_fields_options" do
        it "returns hash of active fields with mapped options" do
          result = helper.custom_select_fields_options
          expect(result).to have_key(:participant_type)
          expect(result[:participant_type]).to be_an(Array)
        end

        context "when no select fields are active" do
          let(:org_extra_user_fields) { { "enabled" => true } }

          it "returns empty hash" do
            expect(helper.custom_select_fields_options).to eq({})
          end
        end

        context "when select_fields config is not a Hash" do
          before { allow(Decidim::ExtraUserFields).to receive(:select_fields).and_return(nil) }

          it "returns empty hash" do
            expect(helper.custom_select_fields_options).to eq({})
          end
        end
      end

      describe "#custom_boolean_fields" do
        it "returns active boolean fields" do
          result = helper.custom_boolean_fields
          expect(result).to include(:ngo)
        end

        context "when no boolean fields are active" do
          let(:org_extra_user_fields) { { "enabled" => true } }

          it "returns empty array" do
            expect(helper.custom_boolean_fields).to eq([])
          end
        end

        context "when boolean_fields config is not an Array" do
          before { allow(Decidim::ExtraUserFields).to receive(:boolean_fields).and_return(nil) }

          it "returns empty array" do
            expect(helper.custom_boolean_fields).to eq([])
          end
        end
      end

      describe "#custom_text_fields" do
        it "returns active text fields with required flag" do
          result = helper.custom_text_fields
          expect(result).to have_key(:motto)
          expect(result[:motto]).to be false
        end

        context "when text field is required" do
          let(:org_extra_user_fields) { { "enabled" => true, "text_fields" => { "motto" => { "enabled" => true, "required" => true } } } }

          it "returns true for required flag" do
            result = helper.custom_text_fields
            expect(result[:motto]).to be true
          end
        end

        context "when no text fields are active" do
          let(:org_extra_user_fields) { { "enabled" => true } }

          it "returns empty hash" do
            expect(helper.custom_text_fields).to eq({})
          end
        end
      end

      describe "#custom_select_field_required?" do
        it "delegates to org collection_field_required?" do
          expect(helper.custom_select_field_required?("participant_type")).to be true
        end

        context "when field is optional" do
          let(:org_extra_user_fields) { { "enabled" => true, "select_fields" => { "participant_type" => { "enabled" => true, "required" => false } } } }

          it "returns false" do
            expect(helper.custom_select_field_required?("participant_type")).to be false
          end
        end
      end

      describe "#map_options" do
        it "translates I18n keys and falls back to humanized" do
          options = { "individual" => "decidim.extra_user_fields.participant_types.individual", "other_key" => "" }
          result = helper.map_options(options)

          individual_entry = result.find { |_label, key| key == "individual" }
          expect(individual_entry).not_to be_nil

          other_entry = result.find { |_label, key| key == "other_key" }
          expect(other_entry).not_to be_nil
        end

        context "with missing I18n keys" do
          it "falls back to humanized label" do
            options = { "some_option" => "decidim.nonexistent.key" }
            result = helper.map_options(options)
            expect(result.first[0]).to eq("Key")
          end
        end
      end
    end
  end
end
