# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Metrics
      module Concerns
        # Comments scope across all component types within the participatory space.
        module CommentQueries
          extend ActiveSupport::Concern

          private

          def comments_scope
            Decidim::Comments::Comment.where(
              decidim_participatory_space_type: participatory_space.class.name,
              decidim_participatory_space_id: participatory_space.id
            )
          end
        end
      end
    end
  end
end
