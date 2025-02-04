# frozen_string_literal: true

require "spec_helper"

describe "Admin manages officializations" do
  include_context "with filterable context"

  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::OfficializationsController }

  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    within ".layout-nav" do
      click_on "Participants"
    end
    within ".sidebar-menu" do
      click_on "Participants"
    end
  end

  it "includes export dropdown button" do
    expect(page).to have_content("Export")
  end

  context "when clicking on export csv button" do
    before do
      find("span.exports").click
      click_on "Export CSV"
    end

    it "redirects to officialization index page and display a flash message" do
      expect(page).to have_title("Participants")
      expect(page).to have_content("Export")
      expect(page).to have_content("Your export is currently in progress. You will receive an email when it is complete")
    end
  end
end
