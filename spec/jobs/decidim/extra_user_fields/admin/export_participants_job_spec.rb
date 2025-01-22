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
          ExportParticipantsJob.perform_now(organization, user, format)
          email = last_email
          expect(email.subject).to include("participants")
          attachment = email.attachments.first

          expect(attachment.read.length).to be_positive
          expect(attachment.mime_type).to eq("application/zip")
          expect(attachment.filename).to match(/^participants-[0-9]+-[0-9]+-[0-9]+-[0-9]+\.zip$/)
        end

        context "when format is CSV" do
          it "uses the csv exporter" do
            export_data = double
            expect(Decidim::Exporters::CSV).to(receive(:new).with(anything,
                                                                  Decidim::ExtraUserFields::UserExportSerializer)).and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, "participants", export_data))
              .and_return(double(deliver_now: true))
            ExportParticipantsJob.perform_now(organization, user, format)
          end
        end

        context "when format is JSON" do
          let(:format) { "JSON" }

          it "uses the json exporter" do
            export_data = double
            expect(Decidim::Exporters::JSON)
              .to(receive(:new).with(anything, Decidim::ExtraUserFields::UserExportSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, "participants", export_data))
              .and_return(double(deliver_now: true))
            ExportParticipantsJob.perform_now(organization, user, format)
          end
        end

        context "when format is excel" do
          let(:format) { "Excel" }

          it "uses the excel exporter" do
            export_data = double
            expect(Decidim::Exporters::Excel)
              .to(receive(:new).with(anything, Decidim::ExtraUserFields::UserExportSerializer))
              .and_return(double(export: export_data))
            expect(ExportMailer)
              .to(receive(:export).with(user, "participants", export_data))
              .and_return(double(deliver_now: true))
            ExportParticipantsJob.perform_now(organization, user, format)
          end
        end
      end
    end
  end
end
