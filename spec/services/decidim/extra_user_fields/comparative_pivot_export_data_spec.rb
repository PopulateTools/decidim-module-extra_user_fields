# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    describe ComparativePivotExportData do
      subject { described_class.new(presenter) }

      let(:pivot_table_a) do
        PivotTable.new(
          row_values: %w(female male),
          col_values: %w(21_to_30 31_to_40),
          cells: {
            "female" => { "21_to_30" => 3, "31_to_40" => 1 },
            "male" => { "21_to_30" => 2, "31_to_40" => 5 }
          }
        )
      end

      let(:pivot_table_b) do
        PivotTable.new(
          row_values: %w(female male),
          col_values: %w(21_to_30 31_to_40),
          cells: {
            "female" => { "21_to_30" => 1, "31_to_40" => 4 },
            "male" => { "21_to_30" => 6, "31_to_40" => 2 }
          }
        )
      end

      let(:space_a) { double("SpaceA", title: { "en" => "Space A" }, id: 1) }
      let(:space_b) { double("SpaceB", title: { "en" => "Space B" }, id: 2) }

      describe "#row_header_key" do
        let(:presenter) do
          ComparativePivotPresenter.new(
            { space_a => pivot_table_a },
            row_field: "gender",
            col_field: "age_span"
          )
        end

        it "returns translated field names joined with slash" do
          expect(subject.row_header_key).to eq("Gender / Age span")
        end
      end

      context "with multiple spaces" do
        let(:presenter) do
          ComparativePivotPresenter.new(
            { space_a => pivot_table_a, space_b => pivot_table_b },
            row_field: "gender",
            col_field: "age_span"
          )
        end

        describe "#rows" do
          it "returns an array of hashes with correct size" do
            expect(subject.rows.size).to eq(3)
          end

          it "includes space-prefixed column headers" do
            first_row = subject.rows.first
            expect(first_row.keys).to include("[Space A] / 21 to 30", "[Space A] / 31 to 40", "[Space A] / Row Total")
            expect(first_row.keys).to include("[Space B] / 21 to 30", "[Space B] / 31 to 40", "[Space B] / Row Total")
            expect(first_row.keys).to include("Row Total")
          end

          it "includes correct data values for first space" do
            first_row = subject.rows.first
            expect(first_row["[Space A] / 21 to 30"]).to eq(3)
            expect(first_row["[Space A] / 31 to 40"]).to eq(1)
            expect(first_row["[Space A] / Row Total"]).to eq(4)
          end

          it "includes correct data values for second space" do
            first_row = subject.rows.first
            expect(first_row["[Space B] / 21 to 30"]).to eq(1)
            expect(first_row["[Space B] / 31 to 40"]).to eq(4)
            expect(first_row["[Space B] / Row Total"]).to eq(5)
          end

          it "includes combined total" do
            first_row = subject.rows.first
            expect(first_row["Row Total"]).to eq(9)
          end

          it "includes correct totals row" do
            totals = subject.rows.last
            expect(totals[subject.row_header_key]).to eq("Column Total")
            expect(totals["[Space A] / 21 to 30"]).to eq(5)
            expect(totals["[Space A] / 31 to 40"]).to eq(6)
            expect(totals["[Space A] / Row Total"]).to eq(11)
            expect(totals["[Space B] / 21 to 30"]).to eq(7)
            expect(totals["[Space B] / 31 to 40"]).to eq(6)
            expect(totals["[Space B] / Row Total"]).to eq(13)
            expect(totals["Row Total"]).to eq(24)
          end
        end
      end

      context "with single space" do
        let(:presenter) do
          ComparativePivotPresenter.new(
            { space_a => pivot_table_a },
            row_field: "gender",
            col_field: "age_span"
          )
        end

        describe "#rows" do
          it "returns an array of hashes with correct size" do
            expect(subject.rows.size).to eq(3)
          end

          it "uses plain column headers without prefix" do
            first_row = subject.rows.first
            expect(first_row.keys).to include("21 to 30", "31 to 40", "Row Total")
            expect(first_row.keys.none? { |k| k.include?("[") }).to be(true)
          end

          it "includes correct data values" do
            first_row = subject.rows.first
            expect(first_row["21 to 30"]).to eq(3)
            expect(first_row["31 to 40"]).to eq(1)
            expect(first_row["Row Total"]).to eq(4)
          end

          it "includes correct totals row" do
            totals = subject.rows.last
            expect(totals[subject.row_header_key]).to eq("Column Total")
            expect(totals["21 to 30"]).to eq(5)
            expect(totals["31 to 40"]).to eq(6)
            expect(totals["Row Total"]).to eq(11)
          end
        end
      end

      context "with nil values (not specified)" do
        let(:pivot_table_a) do
          PivotTable.new(
            row_values: ["female", nil],
            col_values: ["21_to_30"],
            cells: {
              "female" => { "21_to_30" => 2 },
              nil => { "21_to_30" => 1 }
            }
          )
        end

        let(:pivot_table_b) do
          PivotTable.new(
            row_values: ["female"],
            col_values: ["21_to_30"],
            cells: {
              "female" => { "21_to_30" => 3 }
            }
          )
        end

        let(:presenter) do
          ComparativePivotPresenter.new(
            { space_a => pivot_table_a, space_b => pivot_table_b },
            row_field: "gender",
            col_field: "age_span"
          )
        end

        it "labels nil values as not specified" do
          row_labels = subject.rows.map { |r| r[subject.row_header_key] }
          expect(row_labels).to include("Not specified / Prefer not to say")
        end
      end
    end
  end
end
