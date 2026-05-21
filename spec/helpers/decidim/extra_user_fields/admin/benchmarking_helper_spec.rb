# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraUserFields::Admin
  describe BenchmarkingHelper do
    let(:presenter) do
      instance_double(
        Decidim::ExtraUserFields::ComparativePivotPresenter,
        cell: 5,
        cell_style: "--i:0.5;--tc:#1a1a1a;",
        combined_row_total: 10,
        row_total_style: "--i:0.8;--tc:#fff;",
        space_col_total: 7,
        col_total_style: "--i:0.6;--tc:#1a1a1a;",
        combined_grand_total: 33,
        space_label: "My Space"
      )
    end

    before do
      allow(helper).to receive(:comparative_pivot_presenter).and_return(presenter)
    end

    describe "#space_option_label" do
      it "returns type and translated title" do
        space = create(:participatory_process, title: { "en" => "My Process" })
        label = helper.space_option_label(space)
        expect(label).to include("My Process")
        expect(label).to match(/\[.*\]/)
      end

      it "falls back to first locale when current locale is missing" do
        space = create(:participatory_process, title: { "fr" => "Mon Processus" })
        label = helper.space_option_label(space)
        expect(label).to include("Mon Processus")
      end

      it "handles string titles" do
        space = OpenStruct.new(title: "Plain Title", class: Decidim::ParticipatoryProcess)
        label = helper.space_option_label(space)
        expect(label).to include("Plain Title")
        expect(label).to match(/\[.*\]/)
      end
    end

    describe "#space_option_value" do
      it "returns ClassName:id format" do
        space = create(:participatory_process)
        result = helper.space_option_value(space)
        expect(result).to eq("#{space.class.name}:#{space.id}")
      end
    end

    describe "#benchmarking_data_cell" do
      it "renders a td with heatmap-cell--colored class for non-nil row and col" do
        result = helper.benchmarking_data_cell(:space, "female", "young", space_index: 0, col_index: 0)
        expect(result).to include("heatmap-cell--colored")
        expect(result).to include("--i:")
        expect(result).to include("<td")
      end

      it "renders a td with heatmap-cell--gray class when row is nil" do
        result = helper.benchmarking_data_cell(:space, nil, "young", space_index: 0, col_index: 0)
        expect(result).to include("heatmap-cell--gray")
      end

      it "renders a td with heatmap-cell--gray class when col is nil" do
        result = helper.benchmarking_data_cell(:space, "female", nil, space_index: 0, col_index: 0)
        expect(result).to include("heatmap-cell--gray")
      end

      it "adds space-divider class on col_index 0 after first space" do
        result = helper.benchmarking_data_cell(:space, "female", "young", space_index: 1, col_index: 0)
        expect(result).to include("insights-table__space-divider")
      end

      it "does not add space-divider class on first space" do
        result = helper.benchmarking_data_cell(:space, "female", "young", space_index: 0, col_index: 0)
        expect(result).not_to include("insights-table__space-divider")
      end

      it "does not add space-divider class on non-zero col_index" do
        result = helper.benchmarking_data_cell(:space, "female", "young", space_index: 1, col_index: 1)
        expect(result).not_to include("insights-table__space-divider")
      end

      it "includes style attribute from presenter" do
        result = helper.benchmarking_data_cell(:space, "female", "young", space_index: 0, col_index: 0)
        expect(result).to include('style="--i:0.5;--tc:#1a1a1a;"')
      end
    end

    describe "#benchmarking_row_total_cell" do
      it "renders a td with row-total and heatmap-total classes" do
        result = helper.benchmarking_row_total_cell("female")
        expect(result).to include("insights-table__row-total")
        expect(result).to include("heatmap-total")
        expect(result).to include("10")
      end

      it "includes style from presenter" do
        result = helper.benchmarking_row_total_cell("female")
        expect(result).to include("--i:0.8")
      end
    end

    describe "#benchmarking_col_total_cell" do
      it "renders a td with col-total and heatmap-total classes" do
        result = helper.benchmarking_col_total_cell(:space, "young", space_index: 0, col_index: 0)
        expect(result).to include("insights-table__col-total")
        expect(result).to include("heatmap-total")
        expect(result).to include("7")
      end

      it "adds space-divider on col_index 0 after first space" do
        result = helper.benchmarking_col_total_cell(:space, "young", space_index: 1, col_index: 0)
        expect(result).to include("insights-table__space-divider")
      end

      it "does not add space-divider on first space" do
        result = helper.benchmarking_col_total_cell(:space, "young", space_index: 0, col_index: 0)
        expect(result).not_to include("insights-table__space-divider")
      end
    end

    describe "#benchmarking_grand_total_cell" do
      it "renders a td with grand-total class" do
        result = helper.benchmarking_grand_total_cell
        expect(result).to include("insights-table__grand-total")
        expect(result).to include("33")
      end
    end

    describe "#space_name" do
      it "returns plain text for short names" do
        allow(presenter).to receive(:space_label).and_return("Short Name")
        result = helper.space_name(:space)
        expect(result).to eq("Short Name")
      end

      it "returns a span with title for long names" do
        long_name = "A" * 50
        allow(presenter).to receive(:space_label).and_return(long_name)
        result = helper.space_name(:space)
        expect(result).to include("<span")
        expect(result).to include("title=\"#{long_name}\"")
        expect(result).to include("cursor: help")
      end

      it "respects custom limit parameter" do
        name = "A" * 25
        allow(presenter).to receive(:space_label).and_return(name)
        result = helper.space_name(:space, limit: 20)
        expect(result).to include("<span")
      end
    end
  end
end
