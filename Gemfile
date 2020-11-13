# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", git: "https://github.com/decidim/decidim"
gem "decidim-extra_user_fields", path: "."

gem "bootsnap", "~> 1.4"
gem "country_select", "~> 4.0"
gem "puma", ">= 4.3"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", git: "https://github.com/decidim/decidim"
end

group :development do
  gem "faker", "~> 2.14"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end
