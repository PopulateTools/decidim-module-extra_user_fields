# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Organization do
    subject(:organization) { build(:organization, extra_user_fields: extra_user_fields) }

    let(:extra_user_fields) do
      {
        "enabled" => extra_user_field,
        "date_of_birth" => date_of_birth
      }
    end
    let(:extra_user_field) { true }
    let(:date_of_birth) do
      { "enabled" => true }
    end

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    describe "#extra_user_fields_enabled?" do
      it "returns true" do
        expect(subject).to be_extra_user_fields_enabled
      end

      context "when extra user fields are disabled" do
        let(:extra_user_field) { false }

        it "returns true" do
          expect(subject).not_to be_extra_user_fields_enabled
        end
      end
    end

    describe "#activated_extra_field?" do
      it "returns the value of given key" do
        expect(subject).to be_activated_extra_field(:date_of_birth)
      end

      context "when given key doesn't exist in hash" do
        it "returns false" do
          expect(subject).not_to be_activated_extra_field(:unknown)
        end
      end

      context "when value for given key is nil" do
        let(:date_of_birth) { nil }

        it "returns false" do
          expect(subject).not_to be_activated_extra_field(:date_of_birth)
        end
      end
    end
  end
end
