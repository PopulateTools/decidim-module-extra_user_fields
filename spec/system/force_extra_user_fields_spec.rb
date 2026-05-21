# frozen_string_literal: true

require "spec_helper"

describe "Force extra user fields completion" do
  let(:organization) { create(:organization, extra_user_fields:) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let(:user) { create(:user, :confirmed, organization:, password:, extended_data:) }
  let(:extended_data) { {} }

  let(:all_fields_disabled) do
    {
      "enabled" => true,
      "country" => { "enabled" => false, "required" => false },
      "gender" => { "enabled" => false, "required" => false },
      "date_of_birth" => { "enabled" => false, "required" => false },
      "postal_code" => { "enabled" => false, "required" => false },
      "age_range" => { "enabled" => false, "required" => false },
      "phone_number" => { "enabled" => false, "required" => false },
      "location" => { "enabled" => false, "required" => false }
    }
  end

  let(:extra_user_fields) do
    {
      "enabled" => true,
      "country" => { "enabled" => true, "required" => true },
      "gender" => { "enabled" => true, "required" => true },
      "date_of_birth" => { "enabled" => false, "required" => false },
      "postal_code" => { "enabled" => false, "required" => false },
      "age_range" => { "enabled" => false, "required" => false },
      "phone_number" => { "enabled" => false, "required" => false },
      "location" => { "enabled" => false, "required" => false }
    }
  end

  before do
    switch_to_host(organization.host)
  end

  context "when user has NOT completed extra fields" do
    it "redirects to account page with a warning" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")
    end

    it "allows access to the account page and highlights empty required fields" do
      login_as user, scope: :user
      visit decidim.account_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Country")
      expect(page).to have_content("Which gender do you identify with?")
      expect(page).to have_css("label[for='user_country'].is-invalid-label")
      expect(page).to have_css("label[for='user_gender'].is-invalid-label")
    end

    it "allows access to the delete account page" do
      login_as user, scope: :user
      visit decidim.delete_account_path

      expect(page).to have_current_path(decidim.delete_account_path)
    end

    it "allows access to the download your data page" do
      login_as user, scope: :user
      visit decidim.download_your_data_path

      expect(page).to have_current_path(decidim.download_your_data_path)
    end

    it "allows free navigation after completing profile" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_css("label[for='user_country'].is-invalid-label")
      expect(page).to have_css("label[for='user_gender'].is-invalid-label")

      within "form.edit_user" do
        select "Argentina", from: :user_country
        select "Female", from: :user_gender
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      visit decidim.notifications_settings_path
      expect(page).to have_current_path(decidim.notifications_settings_path)
    end
  end

  context "when user HAS completed extra fields" do
    let(:extended_data) { { "country" => "ES", "gender" => "female" } }

    it "does not redirect and allows normal navigation" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
      expect(page).to have_no_content("Please complete your profile information before continuing.")
    end
  end

  context "when all fields are optional (none required)" do
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "country" => { "enabled" => true, "required" => false },
        "gender" => { "enabled" => true, "required" => false }
      }
    end

    it "does not redirect" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when extra user fields module is disabled" do
    let(:extra_user_fields) { { "enabled" => false, "country" => { "enabled" => true, "required" => true } } }

    it "does not redirect" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when user has not accepted ToS and has incomplete extra fields" do
    let(:user) { create(:user, :confirmed, :tos_not_accepted, organization:, password:, extended_data:) }

    it "redirects to ToS page first, then to account page after accepting ToS" do
      login_as user, scope: :user
      visit decidim.root_path

      tos_page = Decidim::StaticPage.find_by(slug: "terms-of-service", organization:)

      expect(page).to have_current_path(decidim.page_path(tos_page))
      expect(page).to have_content("Review updates to our terms of service")

      click_on "I agree with these terms"

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")
    end
  end

  context "when completing a required collection field" do
    let(:extra_user_fields) { all_fields_disabled.merge("select_fields" => { "participant_type" => { "enabled" => true, "required" => true } }) }

    it "allows free navigation after filling the field" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)

      within "form.edit_user" do
        select "Individual", from: "user_select_fields_participant_type"
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      visit decidim.notifications_settings_path
      expect(page).to have_current_path(decidim.notifications_settings_path)
    end
  end

  context "when account page is refreshed with incomplete fields" do
    it "stays on account page without redirect loop" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")

      visit decidim.account_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Country")
    end
  end

  context "when using a non-default locale" do
    it "does not cause a redirect loop on account page" do
      login_as user, scope: :user
      visit "#{decidim.root_path}?locale=fr"

      expect(page).to have_current_path(/account/)

      visit "#{decidim.account_path}?locale=fr"

      expect(page).to have_current_path(/account/)
      expect(page).to have_no_content("redirected you too many times")
    end
  end

  context "when ToS is accepted then extra fields redirect kicks in" do
    let(:user) { create(:user, :confirmed, :tos_not_accepted, organization:, password:, extended_data:) }

    it "flows ToS -> account without loop" do
      login_as user, scope: :user
      visit decidim.root_path

      tos_page = Decidim::StaticPage.find_by(slug: "terms-of-service", organization:)
      expect(page).to have_current_path(decidim.page_path(tos_page))

      click_on "I agree with these terms"

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")

      visit decidim.account_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Country")
    end
  end

  context "when only custom collection fields are required" do
    let(:extra_user_fields) { all_fields_disabled.merge("select_fields" => { "participant_type" => { "enabled" => true, "required" => true } }) }

    it "opens account page stably without redirect loop" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)
      expect(page).to have_content("Please complete your profile information before continuing.")

      visit decidim.account_path

      expect(page).to have_current_path(decidim.account_path)
    end
  end

  context "when user completes fields and navigates away" do
    it "does not redirect back to account after completion" do
      login_as user, scope: :user
      visit decidim.root_path

      expect(page).to have_current_path(decidim.account_path)

      within "form.edit_user" do
        select "Argentina", from: :user_country
        select "Female", from: :user_gender
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      visit decidim.root_path
      expect(page).to have_current_path(decidim.root_path)

      visit decidim.root_path
      expect(page).to have_current_path(decidim.root_path)
    end
  end

  context "when user is not logged in" do
    it "does not redirect" do
      visit decidim.root_path

      expect(page).to have_current_path(decidim.root_path)
    end
  end

  describe "per-field redirect behavior" do
    shared_examples "redirects when required field is empty" do |field|
      let(:extra_user_fields) { all_fields_disabled.merge(field => { "enabled" => true, "required" => true }) }

      it "redirects when #{field} is required and empty" do
        login_as user, scope: :user
        visit decidim.root_path

        expect(page).to have_current_path(decidim.account_path)
      end
    end

    shared_examples "no redirect when required field is filled" do |field, value|
      let(:extra_user_fields) { all_fields_disabled.merge(field => { "enabled" => true, "required" => true }) }
      let(:extended_data) { { field => value } }

      it "does not redirect when #{field} is required and filled" do
        login_as user, scope: :user
        visit decidim.root_path

        expect(page).to have_current_path(decidim.root_path)
      end
    end

    shared_examples "redirects when required collection field is empty" do |collection, field|
      let(:extra_user_fields) { all_fields_disabled.merge(collection => { field => { "enabled" => true, "required" => true } }) }

      it "redirects and highlights the field" do
        login_as user, scope: :user
        visit decidim.root_path

        expect(page).to have_current_path(decidim.account_path)
        expect(page).to have_css("label[for='user_#{collection}_#{field}'].is-invalid-label")
      end
    end

    shared_examples "no redirect when required collection field is filled" do |collection, field, value|
      let(:extra_user_fields) { all_fields_disabled.merge(collection => { field => { "enabled" => true, "required" => true } }) }
      let(:extended_data) { { collection => { field => value } } }

      it "does not redirect when #{collection}.#{field} is required and filled" do
        login_as user, scope: :user
        visit decidim.root_path

        expect(page).to have_current_path(decidim.root_path)
      end
    end

    context "with profile fields" do
      %w(country gender date_of_birth postal_code age_range phone_number location).each do |field|
        values = {
          "country" => "ES", "gender" => "female", "date_of_birth" => "1990-01-01",
          "postal_code" => "08001", "age_range" => "17_to_30", "phone_number" => "+34600000000",
          "location" => "Barcelona"
        }

        it_behaves_like "redirects when required field is empty", field
        it_behaves_like "no redirect when required field is filled", field, values[field]
      end
    end

    context "with collection fields" do
      it_behaves_like "redirects when required collection field is empty", "select_fields", "participant_type"
      it_behaves_like "no redirect when required collection field is filled", "select_fields", "participant_type", "individual"

      it_behaves_like "redirects when required collection field is empty", "text_fields", "motto"
      it_behaves_like "no redirect when required collection field is filled", "text_fields", "motto", "Carpe diem"
    end
  end
end
