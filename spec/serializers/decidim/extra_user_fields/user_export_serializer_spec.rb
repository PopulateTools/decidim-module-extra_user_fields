# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraUserFields::UserExportSerializer do
  subject { described_class.new(resource) }

  let(:resource) { create(:user, extended_data: registration_metadata) }
  # rubocop:disable Style/TrailingCommaInHashLiteral
  let(:registration_metadata) do
    {
      gender:,
      postal_code:,
      date_of_birth:,
      country:,
      phone_number:,
      location:,
      underage:,
      statutory_representative_email:,
      # Block ExtraUserFields ExtraUserFields

      # EndBlock
    }
  end
  # rubocop:enable Style/TrailingCommaInHashLiteral

  let(:gender) { "other" }
  let(:postal_code) { "00000" }
  let(:date_of_birth) { "01/01/2000" }
  let(:country) { "Argentina" }
  let(:phone_number) { "0123456789" }
  let(:location) { "Cahors" }
  let(:underage) { true }
  let(:underage_limit) { 18 }
  let(:statutory_representative_email) { "parent@example.org" }
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

    it "includes the phone number" do
      expect(serialized).to include(phone_number: resource.extended_data["phone_number"])
    end

    it "includes the location" do
      expect(serialized).to include(location: resource.extended_data["location"])
    end

    # Block ExtraUserFields IncludeExtraField

    # EndBlock
  end
end
