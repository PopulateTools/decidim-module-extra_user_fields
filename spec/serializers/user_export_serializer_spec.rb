# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraUserFields::UserExportSerializer do
  let(:subject) { described_class.new(resource) }
  let(:resource) { create(:user, extended_data: registration_metadata) }
  # rubocop:disable Style/TrailingCommaInHashLiteral
  let(:registration_metadata) do
    {
      gender: gender,
      postal_code: postal_code,
      date_of_birth: date_of_birth,
      country: country,
      # Block ExtraUserFields ExtraUserFields

      # EndBlock
    }
  end
  # rubocop:enable Style/TrailingCommaInHashLiteral

  let(:gender) { "Other" }
  let(:postal_code) { "00000" }
  let(:date_of_birth) { "01/01/2000" }
  let(:country) { "Argentina" }
  # Block ExtraUserFields RspecVar

  # EndBlock
  let(:serialized) { subject.serialize }

  describe "#serialize" do
    it "includes the id" do
      expect(serialized).to include(id: resource.id)
    end

    it "includes the gender" do
      expect(serialized).to include(gender: resource.extended_data["gender"])
    end

    it "includes the postal code" do
      expect(serialized).to include(postal_code: resource.extended_data["postal_code"])
    end

    it "includes the date of birth" do
      expect(serialized).to include(date_of_birth: resource.extended_data["date_of_birth"])
    end

    it "includes the country" do
      expect(serialized).to include(country: resource.extended_data["country"])
    end

    # Block ExtraUserFields IncludeExtraField

    # EndBlock
  end
end
