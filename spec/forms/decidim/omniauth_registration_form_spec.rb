# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OmniauthRegistrationForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        current_organization: organization
      )
    end

    let(:organization) { create(:organization) }
    let(:name) { "Facebook User" }
    let(:email) { "user@from-facebook.com" }
    let(:provider) { "facebook" }
    let(:uid) { "12345" }
    let(:oauth_signature) { OmniauthRegistrationForm.create_signature(provider, uid) }
    let(:country) { "Argentina" }
    let(:date_of_birth) { "01/01/2000" }
    let(:gender) { "Other" }
    let(:location) { "Paris" }
    let(:phone_number) { "0123456789" }
    let(:postal_code) { "75001" }

    let(:attributes) do
      {
        email: email,
        email_verified: true,
        name: name,
        provider: provider,
        uid: uid,
        oauth_signature: oauth_signature,
        avatar_url: "http://www.example.org/foo.jpg",
        country: country,
        postal_code: postal_code,
        date_of_birth: date_of_birth,
        gender: gender,
        phone_number: phone_number,
        location: location
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when name is blank" do
      let(:name) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when email is blank" do
      let(:email) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when provider is blank" do
      let(:provider) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when uid is blank" do
      let(:uid) { "" }

      it { is_expected.not_to be_valid }
    end
  end
end
