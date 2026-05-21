# frozen_string_literal: true

require "decidim/extra_user_fields/admin"
require "decidim/extra_user_fields/engine"
require "decidim/extra_user_fields/admin_engine"
require "decidim/extra_user_fields/insights_engine"
require "decidim/extra_user_fields/form_builder_methods"

module Decidim
  # This namespace holds the logic of the `ExtraUserFields` module.
  module ExtraUserFields
    include ActiveSupport::Configurable

    PROFILE_FIELDS = %w(country postal_code date_of_birth gender age_range phone_number location).freeze

    config_accessor :underage_limit do
      ENV.fetch("EXTRA_USER_FIELDS_UNDERAGE_LIMIT", 18).to_i
    end

    config_accessor :underage_options do
      ENV.fetch("EXTRA_USER_FIELDS_UNDERAGE_OPTIONS", "15 16 17 18 19 20 21").split.map(&:to_i)
    end

    # These options require the I18n translations to be set in the locale files.
    # decidim.extra_user_fields.genders.female
    # decidim.extra_user_fields.genders.male
    # decidim.extra_user_fields.genders. ...
    config_accessor :genders do
      ENV.fetch("EXTRA_USER_FIELDS_GENDERS", "female male other prefer_not_to_say").split
    end

    # These options require the I18n translations to be set in the locale files.
    # decidim.extra_user_fields.age_range.up_to_16
    # decidim.extra_user_fields.age_range.17_to_30
    # decidim.extra_user_fields.age_range. ...
    config_accessor :age_ranges do
      ENV.fetch("EXTRA_USER_FIELDS_AGE_RANGES", "up_to_16 17_to_30 31_to_60 61_or_more prefer_not_to_say").split
    end

    # If extra select fields are needed, they can be added as a Hash here.
    # The key is the field name and the value is a hash with the options.
    # You can (optionally) add I18n keys for the options (if not the text will be used as it is).
    # For the user interface, you can defined labels and descriptions for the fields (optionally):
    # decidim.extra_user_fields.select_fields.field_name.label
    # decidim.extra_user_fields.select_fields.field_name.description
    # For the admin interface, you can defined labels and descriptions for the fields (optionally):
    # decidim.extra_user_fields.admin.extra_user_fields.select_fields.field_name.label
    # decidim.extra_user_fields.admin.extra_user_fields.select_fields.field_name.description
    config_accessor :select_fields do
      {
        participant_type: {
          # "" => "",
          "individual" => "decidim.extra_user_fields.participant_types.individual",
          "organization" => "decidim.extra_user_fields.participant_types.organization"
        }
      }
    end

    # If extra boolean fields are needed, they can be added as an Array here.
    # For the user interface, you can defined labels and descriptions for the fields (optionally):
    # decidim.extra_user_fields.boolean_fields.field_name.label
    # decidim.extra_user_fields.boolean_fields.field_name.description
    # For the admin interface, you can defined labels and descriptions for the fields (optionally):
    # decidim.extra_user_fields.admin.extra_user_fields.boolean_fields.field_name.label
    # decidim.extra_user_fields.admin.extra_user_fields.boolean_fields.field_name.description
    config_accessor :boolean_fields do
      [:ngo]
    end

    # If extra text fields are needed, they can be added as an Array here.
    # For the user interface, you can defined labels and descriptions for the fields (optionally):
    # decidim.extra_user_fields.text_fields.field_name.label
    # decidim.extra_user_fields.text_fields.field_name.description
    # For the admin interface, you can defined labels and descriptions for the fields (optionally):
    # decidim.extra_user_fields.admin.extra_user_fields.text_fields.field_name.label
    # decidim.extra_user_fields.admin.extra_user_fields.text_fields.field_name.description
    config_accessor :text_fields do
      [:motto]
    end

    # Extra user fields allowed as pivot table axes in the Insights page.
    # Only categorical fields with limited unique values make sense here.
    config_accessor :insight_fields do
      ENV.fetch("EXTRA_USER_FIELDS_INSIGHT_FIELDS", "gender age_span country").split
    end

    # Age spans used by InsightFields::AgeSpan to bucket computed ages from date_of_birth.
    # These are distinct from `age_ranges` (the form dropdown values).
    config_accessor :insight_age_spans do
      ENV.fetch("EXTRA_USER_FIELDS_INSIGHT_AGE_SPANS", "up_to_20 21_to_30 31_to_40 41_to_50 51_to_60 61_or_more").split
    end

    # If extra insight metrics are needed, they can be added as a Hash here.
    # The key is the metric identifier and the value is a fully-qualified class name.
    # Each class must implement `initialize(participatory_space)` and `call` returning { user_id => count }.
    config_accessor :insight_metrics do
      {
        "participants" => "Decidim::ExtraUserFields::Metrics::ParticipantsMetric",
        "proposals_created" => "Decidim::ExtraUserFields::Metrics::ProposalsCreatedMetric",
        "proposals_supported" => "Decidim::ExtraUserFields::Metrics::ProposalsSupportedMetric",
        "comments" => "Decidim::ExtraUserFields::Metrics::CommentsMetric",
        "budget_votes" => "Decidim::ExtraUserFields::Metrics::BudgetVotesMetric"
      }
    end

    # Always return strings, regardless of whether the initializer used symbols or strings.
    [:genders, :age_ranges, :insight_fields, :insight_age_spans].each do |accessor|
      define_singleton_method(accessor) do
        Array(config.send(accessor)).map(&:to_s)
      end
    end
  end
end
