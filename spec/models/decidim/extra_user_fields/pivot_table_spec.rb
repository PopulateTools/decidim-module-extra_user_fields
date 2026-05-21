# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe PivotTable do
    subject(:pivot_table) { described_class.new(row_values: row_values, col_values: col_values, cells: cells) }

    let(:row_values) { %w(18_to_25 26_to_40) }
    let(:col_values) { %w(female male) }
    let(:cells) do
      {
        "18_to_25" => { "female" => 10, "male" => 5 },
        "26_to_40" => { "female" => 20, "male" => 15 }
      }
    end

    describe "#cell" do
      it "returns the count for a given row and column" do
        expect(pivot_table.cell("18_to_25", "female")).to eq(10)
        expect(pivot_table.cell("26_to_40", "male")).to eq(15)
      end

      it "returns 0 for missing cells" do
        expect(pivot_table.cell("unknown", "female")).to eq(0)
      end
    end

    describe "#row_total" do
      it "sums all columns for a given row" do
        expect(pivot_table.row_total("18_to_25")).to eq(15)
        expect(pivot_table.row_total("26_to_40")).to eq(35)
      end
    end

    describe "#col_total" do
      it "sums all rows for a given column" do
        expect(pivot_table.col_total("female")).to eq(30)
        expect(pivot_table.col_total("male")).to eq(20)
      end
    end

    describe "#grand_total" do
      it "returns the sum of all cells" do
        expect(pivot_table.grand_total).to eq(50)
      end
    end

    describe "#max_value" do
      it "returns the highest cell value" do
        expect(pivot_table.max_value).to eq(20)
      end
    end

    describe "#specified_cell_range" do
      it "returns min and max among all non-zero cells" do
        expect(pivot_table.specified_cell_range).to eq([5, 20])
      end

      context "with nil rows/cols" do
        let(:row_values) { ["18_to_25", nil] }
        let(:col_values) { ["female", nil] }
        let(:cells) { { "18_to_25" => { "female" => 10, nil => 3 }, nil => { "female" => 7, nil => 1 } } }

        it "excludes cells where row or col is nil" do
          expect(pivot_table.specified_cell_range).to eq([10, 10])
        end
      end
    end

    describe "#all_cell_range" do
      it "returns min and max among all cells" do
        expect(pivot_table.all_cell_range).to eq([5, 20])
      end
    end

    describe "#row_total_max" do
      it "returns the highest row total" do
        expect(pivot_table.row_total_max).to eq(35)
      end
    end

    describe "#col_total_max" do
      it "returns the highest column total" do
        expect(pivot_table.col_total_max).to eq(30)
      end
    end

    describe "#empty?" do
      it "returns false when there is data" do
        expect(pivot_table.empty?).to be(false)
      end

      context "when all cells are zero" do
        let(:cells) do
          {
            "18_to_25" => { "female" => 0, "male" => 0 }
          }
        end

        it "returns true" do
          expect(pivot_table.empty?).to be(true)
        end
      end

      context "when there are no cells" do
        let(:row_values) { [] }
        let(:col_values) { [] }
        let(:cells) { {} }

        it "returns true" do
          expect(pivot_table.empty?).to be(true)
        end
      end
    end
  end
end
