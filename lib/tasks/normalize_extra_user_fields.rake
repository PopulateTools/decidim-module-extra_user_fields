# frozen_string_literal: true

require "decidim/extra_user_fields/structure_normalizer"

namespace :decidim_extra_user_fields do
  desc "Normalize extra_user_fields structure from old format to new boolean format"
  task normalize_structure: :environment do
    normalizer = Decidim::ExtraUserFields::StructureNormalizer.new
    normalizer.normalize_all
    puts "✓ Extra user fields structure normalized successfully"
  end
end
