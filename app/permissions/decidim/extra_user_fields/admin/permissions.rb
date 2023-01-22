# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user&.admin?

          allow! if access_extra_user_fields?
          allow! if update_extra_user_fields?

          permission_action
        end

        def access_extra_user_fields?
          permission_action.subject == :extra_user_fields &&
            permission_action.action == :read
        end

        def update_extra_user_fields?
          permission_action.subject == :extra_user_fields &&
            permission_action.action == :update
        end
      end
    end
  end
end
