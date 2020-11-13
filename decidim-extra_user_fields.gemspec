# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/extra_user_fields/version"

Gem::Specification.new do |s|
  s.version = Decidim::ExtraUserFields.version
  s.authors = ["Eduardo Martínez"]
  s.email = ["entantoencuanto.rb@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-extra_user_fields"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-extra_user_fields"
  s.summary = "A decidim extra_user_fields module"
  s.description = "Allows to collect and manage some extra user fields on registration and profile edition."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "country_select", "~> 4.0"
  s.add_dependency "decidim-core", Decidim::ExtraUserFields.decidim_version
  s.add_dependency "deface", "~> 1.5"
end
