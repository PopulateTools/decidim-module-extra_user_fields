# frozen_string_literal: true

require "spec_helper"

describe "Account" do
  shared_examples_for "does not display extra user field" do |field, label|
    it "does not display field '#{field}'" do
      expect(page).to have_no_content(label)
    end
  end

  let(:organization) { create(:organization, extra_user_fields:) }
  let(:user) { create(:user, :confirmed, organization:, password:) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  # rubocop:disable Style/TrailingCommaInHashLiteral
  let(:extra_user_fields) do
    {
      "enabled" => true,
      "date_of_birth" => date_of_birth,
      "postal_code" => postal_code,
      "gender" => gender,
      "country" => country,
      "phone_number" => phone_number,
      "location" => location,
      # Block ExtraUserFields ExtraUserFields

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
    { "enabled" => true, "pattern" => phone_number_pattern, "placeholder" => nil }
  end
  let(:phone_number_pattern) { "^(\\+34)?[0-9 ]{9,12}$" }

  let(:location) do
    { "enabled" => true }
  end

  # Block ExtraUserFields RspecVar

  # EndBlock

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "navigation" do
    it "shows the account form when clicking on the menu" do
      visit decidim.root_path

      within_user_menu do
        find("a", text: "account").click
      end

      expect(page).to have_css("form.edit_user")
    end
  end

  context "when on the account page" do
    before do
      visit decidim.account_path
    end

    it_behaves_like "accessible page"

    describe "updating personal data" do
      let!(:encrypted_password) { user.encrypted_password }

      before do
        within "form.edit_user" do
          select "English", from: :user_locale
          fill_in :user_name, with: "Nikola Tesla"
          fill_in :user_personal_url, with: "https://example.org"
          fill_in :user_about, with: "A Serbian-American inventor, electrical engineer, mechanical engineer, physicist, and futurist."

          fill_in :user_date_of_birth, with: "01/01/2000"
          select "Other", from: :user_gender
          select "Argentina", from: :user_country
          fill_in :user_postal_code, with: "00000"
          fill_in :user_phone_number, with: "0123456789"
          fill_in :user_location, with: "Cahors"
          find("*[type=submit]").click
        end
      end

      it "updates the user's data" do
        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        user.reload

        within_user_menu do
          find("a", text: "My public profile").click
        end

        expect(page).to have_content("example.org")
        expect(page).to have_content("Serbian-American")

        # The user's password should not change when they did not update it
        expect(user.reload.encrypted_password).to eq(encrypted_password)
      end

      context "when updating avatar" do
        it "can update avatar" do
          dynamically_attach_file(:user_avatar, Decidim::Dev.asset("avatar.jpg"))

          within "form.edit_user" do
            find("*[type=submit]").click
          end

          expect(page).to have_css(".flash.success")
        end

        it "shows error when image is too big" do
          find("#user_avatar_button").click

          within ".upload-modal" do
            click_on "Remove"
            input_element = find("input[type='file']", visible: :all)
            input_element.attach_file(Decidim::Dev.asset("5000x5000.png"))

            expect(page).to have_content("File resolution is too large", count: 1)
            expect(page).to have_content("Validation error!")
          end
        end
      end

      context "with phone number pattern blank" do
        let(:phone_number_pattern) { nil }

        it "updates the user's data" do
          within_flash_messages do
            expect(page).to have_content("successfully")
          end
        end
      end

      context "with phone number pattern not compatible with number" do
        let(:phone_number_pattern) { "^(\\+34)?[0-1 ]{9,12}$" }

        it "does not update the user's data" do
          within("label[for='user_phone_number']") do
            expect(page).to have_content("There is an error in this field.")
          end
        end
      end
    end

    context "when date_of_birth is not enabled" do
      let(:date_of_birth) do
        { "enabled" => false }
      end

      it_behaves_like "does not display extra user field", "date_of_birth", "Date of birth"
    end

    context "when postal_code is not enabled" do
      let(:postal_code) do
        { "enabled" => false }
      end

      it_behaves_like "does not display extra user field", "postal_code", "Postal code"
    end

    context "when country is not enabled" do
      let(:country) do
        { "enabled" => false }
      end

      it_behaves_like "does not display extra user field", "country", "Country"
    end

    context "when gender is not enabled" do
      let(:gender) do
        { "enabled" => false }
      end

      it_behaves_like "does not display extra user field", "gender", "Gender"
    end

    context "when phone number is not enabled" do
      let(:phone_number) do
        { "enabled" => false }
      end

      it_behaves_like "does not display extra user field", "phone number", "Phone number"
    end

    context "when location is not enabled" do
      let(:location) do
        { "enabled" => false }
      end

      it_behaves_like "does not display extra user field", "location", "Location"
    end

    describe "when update password" do
      before do
        within "form.edit_user" do
          select "English", from: :user_locale
          fill_in :user_name, with: "Nikola Tesla"
          fill_in :user_personal_url, with: "https://example.org"
          fill_in :user_about, with: "A Serbian-American inventor, electrical engineer, mechanical engineer, physicist, and futurist."

          fill_in :user_date_of_birth, with: "01/01/2000"
          select "Other", from: :user_gender
          select "Argentina", from: :user_country
          fill_in :user_postal_code, with: "00000"
          fill_in :user_phone_number, with: "0123456789"
          fill_in :user_location, with: "Cahors"
          find("*[type=submit]").click
        end
        click_on "Change password"
      end

      let!(:encrypted_password) { user.encrypted_password }
      let(:new_password) { "decidim1234567890" }

      it "toggles old and new password fields" do
        within "form.edit_user" do
          expect(page).to have_content("must not be too common (e.g. 123456) and must be different from your nickname and your email.")
          expect(page).to have_field("user[password]", with: "", type: "password")
          expect(page).to have_field("user[old_password]", with: "", type: "password")
          click_on "Change password"
          expect(page).to have_no_field("user[password]", with: "", type: "password")
          expect(page).to have_no_field("user[old_password]", with: "", type: "password")
        end
      end

      it "shows fields if password is wrong" do
        within "form.edit_user" do
          fill_in "Password", with: new_password
          fill_in "Current password", with: "wrong password12345"
          find("*[type=submit]").click
        end
        expect(page).to have_field("user[password]", with: "decidim1234567890", type: "password")
        expect(page).to have_content("is invalid")
      end

      it "changes the password with correct password" do
        within "form.edit_user" do
          fill_in "Password", with: new_password
          fill_in "Current password", with: password
          find("*[type=submit]").click
        end
        within_flash_messages do
          expect(page).to have_content("successfully")
        end
        expect(user.reload.encrypted_password).not_to eq(encrypted_password)
        expect(page).to have_no_field("user[password]", with: "", type: "password")
        expect(page).to have_no_field("user[old_password]", with: "", type: "password")
      end
    end

    context "when update email" do
      let(:pending_email) { "foo@bar.com" }

      before do
        within "form.edit_user" do
          select "English", from: :user_locale
          fill_in :user_name, with: "Nikola Tesla"
          fill_in :user_personal_url, with: "https://example.org"
          fill_in :user_about, with: "A Serbian-American inventor, electrical engineer, mechanical engineer, physicist, and futurist."

          fill_in :user_date_of_birth, with: "01/01/2000"
          select "Other", from: :user_gender
          select "Argentina", from: :user_country
          fill_in :user_postal_code, with: "00000"
          fill_in :user_phone_number, with: "0123456789"
          fill_in :user_location, with: "Cahors"
          find("*[type=submit]").click
        end
      end

      context "when typing new email" do
        before do
          within "form.edit_user" do
            fill_in "Your email", with: pending_email
            find("*[type=submit]").click
          end
        end

        it "toggles the current password" do
          expect(page).to have_content("In order to confirm the changes to your account, please provide your current password.")
          expect(find("#user_old_password")).to be_visible
          expect(page).to have_content "Current password"
          expect(page).to have_no_content "Password"
        end

        it "renders the old password with error" do
          within "form.edit_user" do
            find("*[type=submit]").click
            fill_in :user_old_password, with: "wrong password"
            find("*[type=submit]").click
          end
          within ".flash.alert" do
            expect(page).to have_content "There was a problem updating your account."
          end
          within ".old-user-password" do
            expect(page).to have_content "is invalid"
          end
        end
      end

      context "when correct old password" do
        before do
          within "form.edit_user" do
            fill_in "Your email", with: pending_email
            find("*[type=submit]").click
            fill_in :user_old_password, with: password

            perform_enqueued_jobs { find("*[type=submit]").click }
          end

          within_flash_messages do
            expect(page).to have_content("You will receive an email to confirm your new email address")
          end
          # 2 emails generated (confirmation + update)
        end

        after do
          clear_enqueued_jobs
        end

        it "tells user to confirm new email" do
          expect(page).to have_content("Email change verification")
          expect(page).to have_css("#user_email[disabled='disabled']")
          expect(page).to have_content("We have sent an email to #{pending_email} to verify your new email address")
        end

        it "resend confirmation" do
          within "#email-change-pending" do
            click_link_or_button "Send again"
          end
          expect(page).to have_content("Confirmation email resent successfully to #{pending_email}")
          perform_enqueued_jobs
          perform_enqueued_jobs

          # the emails include 1 confirmation + 1 update emails added to the 2 previous emails
          expect(emails.count).to eq(4)
          visit last_email_link
          expect(page).to have_content("Your email address has been successfully confirmed")
        end

        it "cancels the email change" do
          expect(Decidim::User.find(user.id).unconfirmed_email).to eq(pending_email)
          within "#email-change-pending" do
            click_link_or_button "cancel"
          end

          expect(page).to have_content("Email change cancelled successfully")
          expect(page).to have_no_content("Email change verification")
          expect(Decidim::User.find(user.id).unconfirmed_email).to be_nil
        end
      end
    end

    context "when on the notifications settings page" do
      before do
        visit decidim.notifications_settings_path
      end

      it "updates the user's notifications" do
        page.find("[for='newsletter_notifications']").click

        within "form.edit_user" do
          find("*[type=submit]").click
        end

        within_flash_messages do
          expect(page).to have_content("successfully")
        end
      end

      context "when the user is an admin" do
        let!(:user) { create(:user, :confirmed, :admin, password:) }

        before do
          login_as user, scope: :user
          visit decidim.notifications_settings_path
        end

        it "updates the administrator's notifications" do
          page.find("[for='email_on_moderations']").click
          page.find("[for='user_notification_settings[close_meeting_reminder]']").click

          within "form.edit_user" do
            find("*[type=submit]").click
          end

          within_flash_messages do
            expect(page).to have_content("successfully")
          end
        end
      end
    end

    context "when on the interests page" do
      before do
        visit decidim.user_interests_path
      end

      it "does not find any scopes" do
        expect(page).to have_content("My interests")
        expect(page).to have_content("This organization does not have any scope yet")
      end

      context "when scopes are defined" do
        let!(:scopes) { create_list(:scope, 3, organization:) }
        let!(:subscopes) { create_list(:subscope, 3, parent: scopes.first) }

        before do
          visit decidim.user_interests_path
        end

        it "display translated scope name" do
          expect(page).to have_content("My interests")
          within "label[for='user_scopes_#{scopes.first.id}_checked']" do
            expect(page).to have_content(translated(scopes.first.name))
          end
        end

        it "allows to choose interests" do
          label_field = "label[for='user_scopes_#{scopes.first.id}_checked']"
          expect(page).to have_content("My interests")
          find(label_field).click
          click_on "Update my interests"

          within_flash_messages do
            expect(page).to have_content("Your interests have been successfully updated.")
          end
        end
      end
    end

    context "when on the delete my account page" do
      before do
        visit decidim.delete_account_path
      end

      it "does not display the authorizations message by default" do
        expect(page).to have_no_content("Some data bound to your authorization will be saved for security.")
      end

      it "the user can delete their account" do
        fill_in :delete_user_delete_account_delete_reason, with: "I just want to delete my account"

        within ".form__wrapper-block" do
          click_on "Delete my account"
        end

        click_on "Yes, I want to delete my account"

        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        click_link_or_button("Log in", match: :first)

        within ".new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: password
          find("*[type=submit]").click
        end

        expect(page).to have_no_content("Signed in successfully")
        expect(page).to have_no_content(user.name)
      end

      context "when the user has an authorization" do
        let!(:authorization) { create(:authorization, :granted, user:) }

        it "displays the authorizations message" do
          visit decidim.delete_account_path

          expect(page).to have_content("Some data bound to your authorization will be saved for security.")
        end
      end
    end
  end

  context "when on the notifications page in a PWA browser" do
    let(:organization) { create(:organization, host: "pwa.lvh.me") }
    let(:user) { create(:user, :confirmed, password:, organization:) }
    let(:password) { "dqCFgjfDbC7dPbrv" }
    let(:vapid_keys) do
      {
        enabled: true,
        public_key: "BKmjw_A8tJCcZNQ72uG8QW15XHQnrGJjHjsmoUILUUFXJ1VNhOnJLc3ywR3eZKibX4HSqhB1hAzZFj__3VqzcPQ=",
        private_key: "TF_MRbSSs_4BE1jVfOsILSJemND8cRMpiznWHgdsro0="
      }
    end

    context "when VAPID keys are set" do
      before do
        Rails.application.secrets[:vapid] = vapid_keys
        driven_by(:pwa_chrome)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      context "when on the account page" do
        it "enables push notifications if supported browser" do
          sleep 2
          page.find("[for='allow_push_notifications']").click

          # Wait for the browser to be subscribed
          sleep 5

          within "form.edit_user" do
            find("*[type=submit]").click
          end

          within_flash_messages do
            expect(page).to have_content("successfully")
          end

          find(:css, "#allow_push_notifications", visible: false).execute_script("this.checked = true")
        end
      end
    end

    context "when VAPID is disabled" do
      before do
        Rails.application.secrets[:vapid] = { enabled: false }
        driven_by(:pwa_chrome)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      it "does not show the push notifications switch" do
        expect(page).to have_no_selector(".push-notifications")
      end
    end

    context "when VAPID keys are not set" do
      before do
        Rails.application.secrets.delete(:vapid)
        driven_by(:pwa_chrome)
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.notifications_settings_path
      end

      it "does not show the push notifications switch" do
        expect(page).to have_no_selector(".push-notifications")
      end
    end
  end
end
