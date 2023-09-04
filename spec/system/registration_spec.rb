# frozen_string_literal: true

require "spec_helper"

def fill_registration_form
  fill_in :registration_user_name, with: "Nikola Tesla"
  fill_in :registration_user_nickname, with: "the-greatest-genius-in-history"
  fill_in :registration_user_email, with: "nikola.tesla@example.org"
  fill_in :registration_user_password, with: "sekritpass123"
  fill_in :registration_user_password_confirmation, with: "sekritpass123"
  page.check("registration_user_newsletter")
  page.check("registration_user_tos_agreement")
end

def fill_extra_user_fields
  fill_in :registration_user_date_of_birth, with: "01/01/2000"
  select "Other", from: :registration_user_gender
  select "Argentina", from: :registration_user_country
  fill_in :registration_user_postal_code, with: "00000"
  fill_in :registration_user_phone_number, with: "0123456789"
  fill_in :registration_user_location, with: "Cahors"
  # Block ExtraUserFields FillExtraUserFields

  # EndBlock
end

describe "Extra user fields", type: :system do
  shared_examples_for "mandatory extra user fields" do |field|
    it "displays #{field} as mandatory" do
      within "label[for='registration_user_#{field}']" do
        expect(page).to have_css("span.label-required")
      end
    end
  end

  let(:organization) { create(:organization, extra_user_fields: extra_user_fields) }
  let!(:terms_and_conditions_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization) }
  # rubocop:disable Style/TrailingCommaInHashLiteral
  let(:extra_user_fields) do
    {
      # Block ExtraUserFields ExtraUserFields
      "enabled" => true,
      "date_of_birth" => date_of_birth,
      "postal_code" => postal_code,
      "gender" => gender,
      "country" => country,
      "phone_number" => phone_number,
      "location" => location,
      # EndBlock
    }
  end
  # rubocop:enable Style/TrailingCommaInHashLiteral

  let(:date_of_birth) do
    { "enabled" => true }
  end

  let(:postal_code) do
    { "enabled" => true }
  end

  let(:country) do
    { "enabled" => true }
  end

  let(:gender) do
    { "enabled" => true }
  end

  let(:phone_number) do
    { "enabled" => true }
  end

  let(:location) do
    { "enabled" => true }
  end

  # Block ExtraUserFields RspecVar

  # EndBlock

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  it "contains extra user fields" do
    within ".card__extra_user_fields" do
      expect(page).to have_content("Date of birth")
      expect(page).to have_content("Gender")
      expect(page).to have_content("Country")
      expect(page).to have_content("Postal code")
      expect(page).to have_content("Phone Number")
      expect(page).to have_content("Location")
      # Block ExtraUserFields ContainsFieldSpec

      # EndBlock
    end
  end

  it "allows to create a new account" do
    fill_registration_form
    fill_extra_user_fields

    within "form.new_user" do
      find("*[type=submit]").click
    end

    expect(page).to have_content("message with a confirmation link has been sent")
  end

  it_behaves_like "mandatory extra user fields", "date_of_birth"
  it_behaves_like "mandatory extra user fields", "gender"
  it_behaves_like "mandatory extra user fields", "country"
  it_behaves_like "mandatory extra user fields", "postal_code"
  it_behaves_like "mandatory extra user fields", "phone_number"
  it_behaves_like "mandatory extra user fields", "location"
  # Block ExtraUserFields ItBehavesLikeSpec

  # EndBlock

  context "when extra_user_fields is disabled" do
    let(:organization) { create(:organization, :extra_user_fields_disabled) }

    it "does not contain extra user fields" do
      expect(page).not_to have_content("Date of birth")
      expect(page).not_to have_content("Gender")
      expect(page).not_to have_content("Country")
      expect(page).not_to have_content("Postal code")
      expect(page).not_to have_content("Phone Number")
      expect(page).not_to have_content("Location")
      # Block ExtraUserFields DoesNotContainFieldSpec

      # EndBlock
    end

    it "allows to create a new account" do
      fill_registration_form

      within "form.new_user" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("message with a confirmation link has been sent")
    end
  end
end
