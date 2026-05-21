# Decidim::ExtraUserFields

This module allows administrators to define a set of extra fields for users. The fields are configurable in the admin panel of the organization. When enabled, they are shown in the user profile and in the registration form.

Supported extra fields for users:

* Country
* Date of birth
* Gender
* Location
* Phone number
* Postal code

This module also enables an Export action in the participants admin panel, which allows to download a list of participants in CSV, JSON or Excel.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-extra_user_fields', github: 'openpoke/decidim-module-extra_user_fields'
```

And then execute:

```bash
bundle
bin/rails decidim:upgrade
bin/rails db:migrate
```

### Upgrading from older versions

If you're upgrading from a version before the boolean structure refactoring, you need to normalize the extra user fields structure. Run the following rake task:

```bash
bin/rails decidim_extra_user_fields:normalize_structure
```

This will convert the old string-based field states (`disabled`/`optional`/`required`) to the new boolean-based structure (`enabled` and `required` boolean flags).

> **EXPERTS ONLY**
>
> Under the hood, when running `bundle exec rails decidim:upgrade` the `decidim-extra_user_fields` gem will run the following (that can also be run manually if you consider):
> 
> ```bash
> bin/rails decidim_extra_user_fields:install:migrations
> ```

You can also the version of the gem that matches your Decidim version:


```ruby
gem "decidim-extra_user_fields", github: "openpoke/decidim-module-extra_user_fields", branch: "release/0.31-stable"
gem "decidim-extra_user_fields", github: "openpoke/decidim-module-extra_user_fields", branch: "release/0.30-stable"
gem "decidim-extra_user_fields", github: "PopulateTools/decidim-module-extra_user_fields", branch: "release/0.29-stable"
```

## Usage

### Admin setup

After installing the gem and migrating the database, you can enable the extra fields in the admin panel of the organization. Go to Participants > Manage extra user fields. There you can enable the fields you want to use and configure whether each field is required or optional. Fields don't include any format validation by default.

![Admin panel](docs/resources/extra_user_fields_admin.gif)

Most of the fields are plain text inputs, but other have a special format:

* Date of birth displays a date picker
* Country displays a country list dropdown

### User signup and profile

Once the fields are enabled, they will be shown in the user signup form and in the user profile.

![User signup](docs/resources/extra_user_fields_signup.png)

![User profile](docs/resources/extra_user_fields_profile.png)


### Admin users export

An extra feature of this plugin is to enable an Export action in the participants admin panel. This action allows to download a list of participants in CSV, JSON or Excel. The fields included in the export are the Decidim User attributes plus the extra fields enabled in the admin panel.

![User export](docs/resources/extra_user_fields_export.gif)


## Configuration

By default, the module is configured to read the configuration from ENV variables.

Currently, the following ENV variables are supported:

| ENV variable | Description | Default value |
| ------------ | ----------- |-------|
| EXTRA_USER_FIELDS_UNDERAGE_LIMIT | The minimum age limit to consider a user as underage. This is used to determine if the user falls into the underage category. | `18` |
| EXTRA_USER_FIELDS_UNDERAGE_OPTIONS | Options for selecting the age for when someone is considered "underage". | `15 16 17 18 19 20 21` |
| EXTRA_USER_FIELDS_GENDERS | Options for the gender field (you need to add the corresponding I18n keys, ie: `decidim.extra_user_fields.genders.prefer_not_to_say` ) | `female male other prefer_not_to_say` |
| EXTRA_USER_FIELDS_AGE_RANGES | Options for the age range field (you need to add the corresponding I18n keys, e.g., `decidim.extra_user_fields.age_ranges.up_to_16`) | `up_to_16 17_to_30 31_to_60 61_or_more prefer_not_to_say` |

## Custom fields

If your use case include fields not defined in this module, it is possible to define custom fields of different types:

1. **Select fields** This configuration option allows you to define any number of extra user fields of the type "Select".
2. **Boolean fields** This configuration option allows you to define any number of extra user fields of the type "Boolean". These fields can be used for true/false values, such as "Accept terms and conditions" or "Subscribe to newsletter".
3. **Text fields** This configuration option allows you to define any number of extra user fields of the type "Text". These fields can be used for free-form text input, such as "Hobbies" or "Favorite quote".


See the next section "Configuration through an initializer" for more information.


### Configuration through an initializer

It is also possible to configure the module using the an initializer:

Create an initializer (for instance `config/initializers/extra_user_fields.rb`) and configure the following:

```ruby
# config/initializers/extra_user_fields.rb

Decidim::ExtraUserFields.configure do |config|
  config.genders = [:female, :male, :other, :prefer_not_to_say]
  config.age_ranges = ["30_or_younger", "31_or_older", "prefer_not_to_say"]
  
  ...


  # I extra select fields are needed, they can be added here.
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
      },
      favorite_pet: {
        "cat" => "my_app.favorite_pets.cat",
        "dog" => "my_app.favorite_pets.dog"
      },
      # It is also possible to specify a proc/lambda that returns a suitable list for the select:
      organization_country: ->(form) { ISO3166::Country.translations(form.locale).invert },
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
    [:ngo, :newsletter]
  end

    # If extra text fields are needed, they can be added as an Array here
  # For the user interface, you can define labels and descriptions for the fields (optionally):
  # decidim.extra_user_fields.text_fields.field_name.label
  # decidim.extra_user_fields.text_fields.field_name.description
  # For the admin interface, you can define labels and descriptions for the fields (optionally):
  # decidim.extra_user_fields.admin.extra_user_fields.text_fields.field_name.label
  # decidim.extra_user_fields.admin.extra_user_fields.text_fields.field_name.description
  config_accessor :text_fields do
    [ :hobbies, :favorite_quote ]
  end
end
```

## Contributing

This module follows the regular git workflow:

* Fork the project from master branch
* Create a feature branch
* Commit your changes
* Open a pull request
* Wait for a review and check that the CI is green

We'll merge the PR ASAP and release a new version of the gem.

### Adding a new field to the module

You can find the development guidelines for adding a new field in this module in the docs/create_new_field.md file.

### Contribute to Decidim

See [Decidim](https://github.com/decidim/decidim).

## Roadmap

Some of the features we would like to add to this module:

* custom validations for the fields
* enable/disable the mandatory flag for each field
* find a way to add the fields to the user export without having to modify this module

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
