# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    describe PivotTableRowSerializer do
      subject { described_class.new(row_hash) }

      let(:row_hash) { { "Row" => "Female", "21 to 30" => 3, "31 to 40" => 1, "Total" => 4 } }

      describe "#serialize" do
        it "returns the resource hash unchanged" do
          expect(subject.serialize).to eq(row_hash)
        end
      end
    end
  end
end
