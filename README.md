# Decidim::ExtraUserFields

* Allows to collect and manage some extra user fields on registration and profile edition.
* Adds a link in admin participants panel to download users of organization in several formats.

## Installation

### For Decidim 0.27 and 0.26

Add this line to your application's Gemfile:

For Decidim 0.27:
```ruby
gem "decidim-extra_user_fields", git: "https://github.com/PopulateTools/decidim-module-extra_user_fields.git", branch: "release/0.27-stable"
```

For Decidim 0.26:
```ruby
gem "decidim-extra_user_fields", git: "https://github.com/PopulateTools/decidim-module-extra_user_fields.git", branch: "release/0.26-stable"
```

And then execute:

```bash
bundle
bundle exec rake railties:install:migrations
bundle exec rake db:migrate
```

### For Decidim 0.25 and 0.24

For Decidim 0.25:
```ruby
gem "decidim-extra_user_fields", git: "https://github.com/PopulateTools/decidim-module-extra_user_fields.git, branch: "release/0.25-stable"
```

For Decidim 0.24:
```ruby
gem "decidim-extra_user_fields", git: "https://github.com/PopulateTools/decidim-module-extra_user_fields.git, branch: "release/0.24-stable"
```

And then execute:

```bash
bundle
```

## Contributing

### Adding a new field to the module

You can fing the development guidelines for adding a new field in this module in the docs/create_new_field.md file.

### Contribute to Decidim

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
