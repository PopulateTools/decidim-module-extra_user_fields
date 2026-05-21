# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe ExportParticipantsJob do
        let(:organization) { create(:organization, extra_user_fields: {}) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:format) { "CSV" }

        it "sends an email with a file attached" do
          perform_enqueued_jobs { ExportParticipantsJob.perform_now(organization, user, format) }
          email = last_email
          expect(email.subject).to include("participants")
          expect(last_email_body).to include("Your download is ready.")
        end

        context "when format is CSV" do
          it "uses the csv exporter" do
            export_data = double(read: "", filename: "participants")
            expect(Decidim::Exporters::CSV).to(receive(:new).with(anything,
                                                                  Decidim::ExtraUserFields::UserExportSerializer)).and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            ExportParticipantsJob.perform_now(organization, user, format)
          end
        end

        context "when format is JSON" do
          let(:format) { "JSON" }

          it "uses the json exporter" do
            export_data = double(read: "", filename: "participants")
            expect(Decidim::Exporters::JSON)
              .to(receive(:new).with(anything, Decidim::ExtraUserFields::UserExportSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            ExportParticipantsJob.perform_now(organization, user, format)
          end
        end

        context "when format is excel" do
          let(:format) { "Excel" }

          it "uses the excel exporter" do
            export_data = double(read: "", filename: "participants")
            expect(Decidim::Exporters::Excel)
              .to(receive(:new).with(anything, Decidim::ExtraUserFields::UserExportSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, kind_of(Decidim::PrivateExport)))
              .and_return(double(deliver_later: true))
            ExportParticipantsJob.perform_now(organization, user, format)
          end
        end
      end
    end
  end
end
