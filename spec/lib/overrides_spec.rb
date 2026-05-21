# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/commands/decidim/create_registration.rb" => "c2fafd313dbe16624e3ef07584e946cd",
      "/app/commands/decidim/create_omniauth_registration.rb" => "31ce55b44db4e53151f11524d26d8832",
      "/app/commands/decidim/update_account.rb" => "2c4f0e5a693b4b46a8e39e12dd9ecb2a",
      "/app/controllers/decidim/application_controller.rb" => "f8936a35f0d919101acad13f7c5a446e",
      "/app/models/decidim/organization.rb" => "977969a742ef2ef7515395fcf6951df7",
      "/app/views/decidim/account/show.html.erb" => "1c230c5c6bc02e0bb22e1ea92b0da96c",
      "/app/views/decidim/devise/registrations/new.html.erb" => "861b8821bbdc05e7b337fcdb921415ba",
      "/app/views/decidim/devise/omniauth_registrations/new.html.erb" => "b972ec211ff96702d449cf6c8846a613"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/views/decidim/admin/officializations/index.html.erb" => "e68f2a9b4887212f21756de25394ff53"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
