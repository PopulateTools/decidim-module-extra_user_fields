# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe ExportPivotDataJob do
        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:process_a) { create(:participatory_process, :with_steps, organization:) }
        let(:format) { "CSV" }
        let(:pivot_params) { { metric: "participants", row_field: "gender", col_field: "age_span" } }

        context "with single space (insights)" do
          let(:spaces) { [process_a] }

          it "sends an export email" do
            perform_enqueued_jobs do
              described_class.perform_now(user, format, spaces, pivot_params, "insights")
            end
            email = last_email
            expect(email.subject).to include("insights")
          end

          it "uses the CSV exporter" do
            export_data = double(read: "", filename: "insights")
            expect(Decidim::Exporters::CSV)
              .to(receive(:new).with(kind_of(Array), PivotTableRowSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            described_class.perform_now(user, format, spaces, pivot_params, "insights")
          end
        end

        context "with multiple spaces (benchmarking)" do
          let!(:process_b) { create(:participatory_process, :with_steps, organization:) }
          let(:spaces) { [process_a, process_b] }

          it "sends an export email" do
            perform_enqueued_jobs do
              described_class.perform_now(user, format, spaces, pivot_params, "benchmarking")
            end
            email = last_email
            expect(email.subject).to include("benchmarking")
          end

          it "uses the CSV exporter" do
            export_data = double(read: "", filename: "benchmarking")
            expect(Decidim::Exporters::CSV)
              .to(receive(:new).with(kind_of(Array), PivotTableRowSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            described_class.perform_now(user, format, spaces, pivot_params, "benchmarking")
          end
        end

        context "when format is JSON" do
          let(:format) { "JSON" }
          let(:spaces) { [process_a] }

          it "uses the JSON exporter" do
            export_data = double(read: "", filename: "insights")
            expect(Decidim::Exporters::JSON)
              .to(receive(:new).with(kind_of(Array), PivotTableRowSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            described_class.perform_now(user, format, spaces, pivot_params, "insights")
          end
        end

        context "when format is Excel" do
          let(:format) { "Excel" }
          let(:spaces) { [process_a] }

          it "uses the Excel exporter" do
            export_data = double(read: "", filename: "insights")
            expect(Decidim::Exporters::Excel)
              .to(receive(:new).with(kind_of(Array), PivotTableRowSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            described_class.perform_now(user, format, spaces, pivot_params, "insights")
          end
        end
      end
    end
  end
end
