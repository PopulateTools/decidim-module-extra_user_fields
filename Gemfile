# frozen_string_literal: true

DECIDIM_VERSION = "~> 0.31.0"

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-extra_user_fields", path: "."
gem "decidim-initiatives", DECIDIM_VERSION

gem "bootsnap", "~> 1.7"
gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 3.3.1"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "web-console", "~> 4.2"
end
