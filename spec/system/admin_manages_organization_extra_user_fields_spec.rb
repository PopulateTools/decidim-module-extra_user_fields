# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization extra user fields", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "creates a new item in submenu" do
    visit decidim_admin.edit_organization_path

    within ".secondary-nav" do
      expect(page).to have_content("Manage extra user fields")
    end
  end

  context "when accessing extra user fields" do
    before do
      visit decidim_extra_user_fields.root_path
    end

    it "displays the form" do
      within "#extra_user_fields" do
        expect(page).to have_content("Manage extra user fields")
      end
    end

    it "allows to enable extra user fields functionality" do
      within ".extra_user_fields" do
        expect(page).to have_content("Enable extra user fields")
      end

      within ".extra_fields_setup" do
        expect(page).to have_content("Available extra fields for signup form")
      end
    end

    context "when form is valid" do
      it "flashes a success message" do
        page.check("extra_user_fields[enabled]")

        find("*[type=submit]").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end
    end
  end
end
