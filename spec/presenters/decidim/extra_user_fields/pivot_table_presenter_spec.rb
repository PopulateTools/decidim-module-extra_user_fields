# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields
  describe PivotTablePresenter do
    subject(:presenter) { described_class.new(pivot_table) }

    let(:pivot_table) { PivotTable.new(row_values: row_values, col_values: col_values, cells: cells) }
    let(:row_values) { %w(female male) }
    let(:col_values) { %w(young old) }
    let(:cells) { { "female" => { "young" => 10, "old" => 5 }, "male" => { "young" => 3, "old" => 2 } } }

    describe "delegation" do
      it "delegates data methods to pivot_table" do
        expect(presenter.row_values).to eq(pivot_table.row_values)
        expect(presenter.col_values).to eq(pivot_table.col_values)
        expect(presenter.cell("female", "young")).to eq(10)
        expect(presenter.row_total("female")).to eq(15)
        expect(presenter.col_total("young")).to eq(13)
        expect(presenter.grand_total).to eq(20)
        expect(presenter.empty?).to be(false)
      end
    end

    describe "#cell_style" do
      it "returns empty string when value is zero" do
        expect(presenter.cell_style(0, "female", "young")).to eq("")
      end

      it "returns CSS variables with intensity and text color" do
        result = presenter.cell_style(10, "female", "young")
        expect(result).to include("--i:")
        expect(result).to include("--tc:")
      end

      it "returns full intensity for the max value" do
        result = presenter.cell_style(10, "female", "young")
        expect(result).to include("--i:1.0")
        expect(result).to include("--tc:#fff")
      end

      it "returns zero intensity for the min value" do
        result = presenter.cell_style(2, "male", "old")
        expect(result).to include("--i:0.0")
        expect(result).to include("--tc:#1a1a1a")
      end

      context "when all specified cells have the same value" do
        let(:cells) { { "female" => { "young" => 5, "old" => 5 }, "male" => { "young" => 5, "old" => 5 } } }

        it "returns zero intensity (no hotspots)" do
          result = presenter.cell_style(5, "female", "young")
          expect(result).to include("--i:0.0")
        end
      end

      context "when row or col is nil" do
        let(:row_values) { ["female", nil] }
        let(:col_values) { ["young", nil] }
        let(:cells) { { "female" => { "young" => 10, nil => 5 }, nil => { "young" => 3, nil => 7 } } }

        it "returns CSS variables for gray cells" do
          result = presenter.cell_style(7, nil, nil)
          expect(result).to include("--i:")
          expect(result).to include("--tc:")
        end

        it "uses all_cell_range for nil cells" do
          result = presenter.cell_style(10, "female", nil)
          expect(result).to include("--i:")
        end
      end
    end

    describe "#row_total_style" do
      it "returns empty string when value is zero" do
        expect(presenter.row_total_style(0)).to eq("")
      end

      it "returns full intensity for the max row total" do
        result = presenter.row_total_style(15)
        expect(result).to include("--i:1.0")
        expect(result).to include("--tc:#fff")
      end

      it "returns proportional intensity for smaller totals" do
        result = presenter.row_total_style(5)
        expect(result).to include("--i:")
        expect(result).to include("--tc:#1a1a1a")
      end
    end

    describe "#col_total_style" do
      it "returns empty string when value is zero" do
        expect(presenter.col_total_style(0)).to eq("")
      end

      it "returns full intensity for the max column total" do
        result = presenter.col_total_style(13)
        expect(result).to include("--i:1.0")
        expect(result).to include("--tc:#fff")
      end

      it "returns proportional intensity for smaller totals" do
        result = presenter.col_total_style(7)
        expect(result).to include("--i:")
        expect(result).to include("--tc:#1a1a1a")
      end
    end

    describe "edge cases" do
      context "when there are no non-nil combinations" do
        let(:row_values) { [nil] }
        let(:col_values) { [nil] }
        let(:cells) { { nil => { nil => 10 } } }

        it "returns CSS variables for the only cell" do
          result = presenter.cell_style(10, nil, nil)
          expect(result).to include("--i:")
        end
      end

      context "when there are no cells" do
        let(:row_values) { [] }
        let(:col_values) { [] }
        let(:cells) { {} }

        it "returns empty string for row total style" do
          expect(presenter.row_total_style(0)).to eq("")
        end

        it "returns empty string for col total style" do
          expect(presenter.col_total_style(0)).to eq("")
        end
      end
    end
  end
end
