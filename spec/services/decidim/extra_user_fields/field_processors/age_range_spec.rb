# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  module FieldProcessors
    describe AgeRange do
      describe ".call" do
        subject { described_class.call(extended_data) }

        context "when date_of_birth is present" do
          let(:extended_data) { { "date_of_birth" => date_of_birth } }

          context "with age in the up_to_20 range" do
            let(:date_of_birth) { 18.years.ago.to_date.to_s }

            it { is_expected.to eq("up_to_20") }
          end

          context "with age in the 21_to_30 range" do
            let(:date_of_birth) { 25.years.ago.to_date.to_s }

            it { is_expected.to eq("21_to_30") }
          end

          context "with age in the 31_to_40 range" do
            let(:date_of_birth) { 35.years.ago.to_date.to_s }

            it { is_expected.to eq("31_to_40") }
          end

          context "with age in the 41_to_50 range" do
            let(:date_of_birth) { 45.years.ago.to_date.to_s }

            it { is_expected.to eq("41_to_50") }
          end

          context "with age in the 51_to_60 range" do
            let(:date_of_birth) { 55.years.ago.to_date.to_s }

            it { is_expected.to eq("51_to_60") }
          end

          context "with age in the 61_or_more range" do
            let(:date_of_birth) { 70.years.ago.to_date.to_s }

            it { is_expected.to eq("61_or_more") }
          end
        end

        context "when only age_range is stored (no date_of_birth)" do
          let(:extended_data) { { "age_range" => "17_to_30" } }

          it "returns nil because stored age_range is ignored" do
            expect(subject).to be_nil
          end
        end

        context "when both date_of_birth and age_range are present" do
          let(:extended_data) { { "age_range" => "17_to_30", "date_of_birth" => 45.years.ago.to_date.to_s } }

          it "uses date_of_birth only" do
            expect(subject).to eq("41_to_50")
          end
        end

        context "when neither age_range nor date_of_birth is present" do
          let(:extended_data) { {} }

          it { is_expected.to be_nil }
        end

        context "with an invalid date_of_birth" do
          let(:extended_data) { { "date_of_birth" => "not-a-date" } }

          it { is_expected.to be_nil }
        end

        context "with a nil date_of_birth" do
          let(:extended_data) { { "date_of_birth" => nil } }

          it { is_expected.to be_nil }
        end

        context "with a future date_of_birth" do
          let(:extended_data) { { "date_of_birth" => 5.years.from_now.to_date.to_s } }

          it { is_expected.to be_nil }
        end
      end

      describe "age boundary precision" do
        subject { described_class.call("date_of_birth" => birth_date.to_s) }

        context "when the user turns 21 today" do
          let(:birth_date) { 21.years.ago.to_date }

          it { is_expected.to eq("21_to_30") }
        end

        context "when the user is still 20 (birthday tomorrow)" do
          let(:birth_date) { 21.years.ago.to_date + 1.day }

          it { is_expected.to eq("up_to_20") }
        end

        context "when the user turns 31 today" do
          let(:birth_date) { 31.years.ago.to_date }

          it { is_expected.to eq("31_to_40") }
        end

        context "when the user is still 30 (birthday tomorrow)" do
          let(:birth_date) { 31.years.ago.to_date + 1.day }

          it { is_expected.to eq("21_to_30") }
        end

        context "when the user turns 41 today" do
          let(:birth_date) { 41.years.ago.to_date }

          it { is_expected.to eq("41_to_50") }
        end

        context "when the user is still 40 (birthday tomorrow)" do
          let(:birth_date) { 41.years.ago.to_date + 1.day }

          it { is_expected.to eq("31_to_40") }
        end

        context "when the user turns 51 today" do
          let(:birth_date) { 51.years.ago.to_date }

          it { is_expected.to eq("51_to_60") }
        end

        context "when the user is still 50 (birthday tomorrow)" do
          let(:birth_date) { 51.years.ago.to_date + 1.day }

          it { is_expected.to eq("41_to_50") }
        end

        context "when the user turns 61 today" do
          let(:birth_date) { 61.years.ago.to_date }

          it { is_expected.to eq("61_or_more") }
        end

        context "when the user is still 60 (birthday tomorrow)" do
          let(:birth_date) { 61.years.ago.to_date + 1.day }

          it { is_expected.to eq("51_to_60") }
        end
      end
    end
  end
end
