# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraUserFields::UserExportSerializer do
  subject { described_class.new(resource) }

  let(:resource) { create(:user, extended_data: registration_metadata) }
  let(:registration_metadata) do
    {
      gender:,
      age_range:,
      postal_code:,
      date_of_birth:,
      country:,
      phone_number:,
      location:,
      underage:,
      select_fields:,
      boolean_fields:,
      text_fields:,
      statutory_representative_email:
    }
  end

  let(:gender) { "other" }
  let(:age_range) { "17_to_30" }
  let(:postal_code) { "00000" }
  let(:date_of_birth) { "01/01/2000" }
  let(:country) { "Argentina" }
  let(:phone_number) { "0123456789" }
  let(:location) { "Cahors" }
  let(:underage) { true }
  let(:underage_limit) { 18 }
  let(:statutory_representative_email) { "parent@example.org" }
  let(:select_fields) do
    {
      "participant_type" => "individual"
    }
  end
  let(:boolean_fields) do
    ["ngo"]
  end
  let(:text_fields) do
    {
      "motto" => "I think, therefore I am"
    }
  end

  let(:serialized) { subject.serialize }

  describe "#serialize" do
    it "includes the id" do
      expect(serialized).to include(id: resource.id)
    end

    it "includes the gender" do
      expect(serialized).to include(gender: resource.extended_data["gender"])
    end

    it "includes the age range" do
      expect(serialized).to include(age_range: resource.extended_data["age_range"])
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

    it "includes the select fields" do
      expect(serialized).to include(select_fields: resource.extended_data["select_fields"])
    end

    it "includes the boolean fields" do
      expect(serialized).to include(boolean_fields: resource.extended_data["boolean_fields"])
    end

    it "includes the text fields" do
      expect(serialized).to include(text_fields: resource.extended_data["text_fields"])
    end

    context "when users are blocked" do
      let(:resource) { create(:user, :blocked, extended_data: registration_metadata, blocked_at:) }
      let(:blocked_at) { Time.zone.now }
      let(:blocking_user) { create(:user, :admin, :confirmed, organization: resource.organization) }
      let(:blocking_justification) { "This is a spam user with suspicious activities" }
      let(:user_block) { double(justification: blocking_justification) }

      before do
        allow(resource).to receive(:blocking).and_return(user_block)
      end

      it "includes the blocked status and justification" do
        expect(serialized).to include(blocked: true)
        expect(serialized).to include(blocked_at:)
        expect(serialized).to include(blocking_justification:)
      end
    end

    # Block ExtraUserFields IncludeExtraField

    # EndBlock
  end
end
