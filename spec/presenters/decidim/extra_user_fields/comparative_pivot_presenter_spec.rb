# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe ComparativePivotPresenter do
    subject(:presenter) { described_class.new(pivot_tables, row_field: "gender", col_field: "age_span") }

    let(:space_a) { OpenStruct.new(title: { "en" => "Space A" }, id: 1) }
    let(:space_b) { OpenStruct.new(title: { "en" => "Space B" }, id: 2) }

    let(:pt_a) { PivotTable.new(row_values: %w(female male), col_values: %w(young old), cells: cells_a) }
    let(:pt_b) { PivotTable.new(row_values: %w(male other), col_values: %w(old young), cells: cells_b) }

    let(:cells_a) { { "female" => { "young" => 10, "old" => 5 }, "male" => { "young" => 3, "old" => 2 } } }
    let(:cells_b) { { "male" => { "old" => 4, "young" => 1 }, "other" => { "old" => 6, "young" => 2 } } }

    let(:pivot_tables) { { space_a => pt_a, space_b => pt_b } }

    describe "#spaces" do
      it "returns the space keys" do
        expect(presenter.spaces).to eq([space_a, space_b])
      end
    end

    describe "#unified_row_values" do
      it "merges and deduplicates row values preserving order" do
        expect(presenter.unified_row_values).to eq(%w(female male other))
      end

      context "with nil in axes" do
        let(:pt_a) { PivotTable.new(row_values: ["female", nil], col_values: %w(young), cells: { "female" => { "young" => 1 }, nil => { "young" => 2 } }) }
        let(:pt_b) { PivotTable.new(row_values: %w(male), col_values: %w(young), cells: { "male" => { "young" => 3 } }) }

        it "places nil last" do
          expect(presenter.unified_row_values).to eq(["female", "male", nil])
        end
      end
    end

    describe "#unified_col_values" do
      it "merges and deduplicates column values preserving order" do
        expect(presenter.unified_col_values).to eq(%w(young old))
      end

      context "with nil in axes" do
        let(:pt_a) { PivotTable.new(row_values: %w(female), col_values: ["young", nil], cells: { "female" => { "young" => 1, nil => 2 } }) }
        let(:pt_b) { PivotTable.new(row_values: %w(female), col_values: %w(old), cells: { "female" => { "old" => 3 } }) }

        it "places nil last" do
          expect(presenter.unified_col_values).to eq(["young", "old", nil])
        end
      end
    end

    describe "#cell" do
      it "returns the correct value for an existing cell" do
        expect(presenter.cell(space_a, "female", "young")).to eq(10)
      end

      it "returns 0 for a missing row in a space" do
        expect(presenter.cell(space_a, "other", "young")).to eq(0)
      end

      it "returns 0 for an unknown space" do
        unknown = OpenStruct.new(title: "Unknown", id: 99)
        expect(presenter.cell(unknown, "female", "young")).to eq(0)
      end
    end

    describe "#space_row_total" do
      it "sums across all unified columns for a row" do
        # space_a, female: young=10 + old=5 = 15
        expect(presenter.space_row_total(space_a, "female")).to eq(15)
      end

      it "returns 0 for a row not in the space" do
        # space_a has no "other" row
        expect(presenter.space_row_total(space_a, "other")).to eq(0)
      end
    end

    describe "#space_col_total" do
      it "sums across all unified rows for a column" do
        # space_b, old: male=4 + other=6 + female=0 = 10
        expect(presenter.space_col_total(space_b, "old")).to eq(10)
      end
    end

    describe "#space_grand_total" do
      it "sums all cells in a space" do
        # space_a: 10+5+3+2 = 20
        expect(presenter.space_grand_total(space_a)).to eq(20)
      end
    end

    describe "#combined_row_total" do
      it "sums a row across all spaces" do
        # male: space_a(3+2) + space_b(1+4) = 10
        expect(presenter.combined_row_total("male")).to eq(10)
      end
    end

    describe "#combined_grand_total" do
      it "sums all cells across all spaces" do
        # space_a: 20, space_b: 1+4+2+6 = 13 => 33
        expect(presenter.combined_grand_total).to eq(33)
      end
    end

    describe "#cell_style" do
      it "returns CSS variables for non-nil row and col" do
        result = presenter.cell_style(10, "female", "young")
        expect(result).to include("--i:")
        expect(result).to include("--tc:")
      end

      it "returns empty string for zero value" do
        expect(presenter.cell_style(0, "female", "young")).to eq("")
      end

      it "uses global_all_range when row is nil" do
        result = presenter.cell_style(5, nil, "young")
        expect(result).to include("--i:")
      end

      it "uses global_all_range when col is nil" do
        result = presenter.cell_style(5, "female", nil)
        expect(result).to include("--i:")
      end
    end

    describe "#row_total_style" do
      it "returns CSS variables for non-zero totals" do
        result = presenter.row_total_style(15)
        expect(result).to include("--i:")
        expect(result).to include("--tc:")
      end

      it "returns empty string for zero" do
        expect(presenter.row_total_style(0)).to eq("")
      end
    end

    describe "#col_total_style" do
      it "returns CSS variables for non-zero totals" do
        result = presenter.col_total_style(10)
        expect(result).to include("--i:")
        expect(result).to include("--tc:")
      end

      it "returns empty string for zero" do
        expect(presenter.col_total_style(0)).to eq("")
      end
    end

    describe "#empty?" do
      it "returns false when data exists" do
        expect(presenter.empty?).to be(false)
      end

      context "when all pivot tables are empty" do
        let(:pt_a) { PivotTable.new(row_values: [], col_values: [], cells: {}) }
        let(:pt_b) { PivotTable.new(row_values: [], col_values: [], cells: {}) }

        it "returns true" do
          expect(presenter.empty?).to be(true)
        end
      end
    end

    describe "#space_label" do
      it "returns translated title from a hash" do
        expect(presenter.space_label(space_a)).to eq("Space A")
      end

      it "falls back to first available locale when current locale missing" do
        space = OpenStruct.new(title: { "fr" => "Espace C" })
        expect(presenter.space_label(space)).to eq("Espace C")
      end

      it "returns string title as-is" do
        space = OpenStruct.new(title: "Plain Title")
        expect(presenter.space_label(space)).to eq("Plain Title")
      end
    end

    context "with a single space" do
      let(:pivot_tables) { { space_a => pt_a } }

      it "works correctly with one space" do
        expect(presenter.spaces).to eq([space_a])
        expect(presenter.unified_row_values).to eq(%w(female male))
        expect(presenter.combined_grand_total).to eq(20)
      end
    end

    context "with no spaces" do
      let(:pivot_tables) { {} }

      it "returns empty collections" do
        expect(presenter.spaces).to eq([])
        expect(presenter.unified_row_values).to eq([])
        expect(presenter.unified_col_values).to eq([])
        expect(presenter.combined_grand_total).to eq(0)
        expect(presenter.empty?).to be(true)
      end
    end
  end
end
