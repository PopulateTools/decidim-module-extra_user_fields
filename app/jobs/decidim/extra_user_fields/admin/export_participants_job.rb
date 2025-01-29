# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExportParticipantsJob < ApplicationJob
        queue_as :exports

        def perform(organization, user, format)
          collection = organization.users.not_deleted
          export_data = Decidim::Exporters.find_exporter(format).new(collection,
                                                                     Decidim::ExtraUserFields::UserExportSerializer).export
          ExportMailer.export(user, "participants", export_data).deliver_now
        end
      end
    end
  end
end
