# frozen_string_literal: true

require "spec_helper"

describe "Admin manages officializations", type: :system do
  include_context "with filterable context"

  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::OfficializationsController }

  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Participants"
  end

  it "includes export dropdown button" do
    click_link "Participants"

    expect(page).to have_content("Export all")
  end
end
