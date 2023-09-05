# Decidim::ExtraUserFields

Extra features for Decidim users.

This plugin allows administrators to define a set of extra fields for users, and to download the users of an organization in several formats.

These fields are configurable in the admin panel of the organization. When enabled, they are shown in the user profile and in the user registration form.

Supported extra fields for users:

* Country
* Date of birth
* Gender
* Location
* Phone number
* Postal code

This plugin also enables an Export action in the participants admin panel, which allows to download a list of participants in CSV, JSON or Excel.

## Installation

Pick the version of the gem that matches your Decidim version.

For Decidim 0.27:

```ruby
gem "decidim-extra_user_fields", git: "https://github.com/PopulateTools/decidim-module-extra_user_fields.git", branch: "release/0.27-stable"
```

For Decidim 0.26:

```ruby
gem "decidim-extra_user_fields", git: "https://github.com/PopulateTools/decidim-module-extra_user_fields.git", branch: "release/0.26-stable"
```

For Decidim 0.25:

```ruby
gem "decidim-extra_user_fields", git: "https://github.com/PopulateTools/decidim-module-extra_user_fields.git", branch: "release/0.25-stable"
```

For Decidim 0.24:

```ruby
gem "decidim-extra_user_fields", git: "https://github.com/PopulateTools/decidim-module-extra_user_fields.git", branch: "release/0.24-stable"
```

And then execute:

```bash
bundle install
# For versions >= 0.27
bundle exec rake railties:install:migrations
bundle exec rake db:migrate
```

## Usage

### Admin setup

After installing the gem and migrating the database, you can enable the extra fields in the admin panel of the organization. Go to Settings > Manage extra user fields. There you can enable the fields you want to use. By default all fields are required and don't include any format validation.

Most of the fields are plain text inputs, but other have a special format:

* Date of birth displays a date picker
* Country displays a country list dropdown

### User signup and profile

Once the fields are enabled, they will be shown in the user signup form and in the user profile.

### Admin users export

An extra feature of this plugin is to enable an Export action in the participants admin panel. This action allows to download a list of participants in CSV, JSON or Excel. The fields included in the export are the Decidim User attributes plus the extra fields enabled in the admin panel.


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
