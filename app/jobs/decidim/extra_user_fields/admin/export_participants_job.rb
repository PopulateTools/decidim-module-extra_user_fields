# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExportParticipantsJob < ApplicationJob
        include Decidim::PrivateDownloadHelper

        queue_as :exports

        def perform(organization, user, format)
          collection = organization.users.not_deleted
          export_data = Decidim::Exporters.find_exporter(format).new(collection,
                                                                     Decidim::ExtraUserFields::UserExportSerializer).export
          private_export = attach_archive(export_data, "participants", user)
          ExportMailer.export(user, private_export).deliver_later
        end
      end
    end
  end
end
