# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # This is the engine that runs on the public interface of `ExtraUserFields`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ExtraUserFields::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :extra_user_fields do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "extra_user_fields#index"
      end

      def load_seed
        nil
      end
    end
  end
end
