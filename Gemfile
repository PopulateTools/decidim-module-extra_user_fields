# frozen_string_literal: true

DECIDIM_VERSION = "~> 0.28"

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-extra_user_fields", path: "."

gem "bootsnap", "~> 1.4"
gem "country_select", "~> 4.0"
gem "puma", ">= 4.3"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 3.3.1"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :test do
  gem "rubocop-factory_bot", "!= 2.26.0", require: false
  gem "rubocop-rspec_rails", "!= 2.29.0", require: false
end
