# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    # This module adds the FormBuilder methods for extra user fields
    module FormBuilderMethods
      def custom_country_select(name, options = {})
        label_text = options[:label].to_s
        label_text = label_for(name) if label_text.blank?

        template = ""
        template += label(name, label_text + required_for_attribute(name)) if options.fetch(:label, true)
        template += country_select(name)
        template.html_safe
      end
    end
  end
end
