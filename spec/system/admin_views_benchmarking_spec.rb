# frozen_string_literal: true

require "spec_helper"

describe "Admin views benchmarking" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when visiting the benchmarking page" do
    before do
      visit decidim_extra_user_fields.benchmarking_path
    end

    it "renders the benchmarking menu item in the sidebar" do
      within(".sidebar-menu") do
        expect(page).to have_content("Benchmarking")
      end
    end

    it "highlights the Insights menu item in the main admin menu" do
      expect(page).to have_css("[aria-current='page']", text: "Insights")
    end

    it "displays the page title" do
      expect(page).to have_content("Comparative stats across spaces")
    end

    it "displays the description" do
      expect(page).to have_content("Choose participatory spaces for comparison")
    end

    it "shows the selector dropdowns" do
      within(".insights-selectors") do
        expect(page).to have_content("Rows (Y axis)")
        expect(page).to have_content("Columns (X axis)")
        expect(page).to have_content("Metric")
      end
    end

    it "shows prompt when no spaces are selected" do
      expect(page).to have_content("Select one or more participatory spaces to compare")
      expect(page).to have_no_table
    end
  end

  context "with participation data in two processes" do
    let!(:process_a) { create(:participatory_process, :with_steps, organization:, title: { "en" => "Process Alpha" }) }
    let!(:process_b) { create(:participatory_process, :with_steps, organization:, title: { "en" => "Process Beta" }) }
    let!(:component_a) { create(:proposal_component, :published, participatory_space: process_a) }
    let!(:component_b) { create(:proposal_component, :published, participatory_space: process_b) }

    let(:user_female_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }
    let(:user_male_old) { create(:user, :confirmed, organization:, extended_data: { "gender" => "male", "date_of_birth" => 55.years.ago.to_date.to_s }) }

    before do
      create(:proposal, :published, component: component_a, users: [user_female_young])
      create(:proposal, :published, component: component_a, users: [user_male_old])
      create(:proposal, :published, component: component_b, users: [user_female_young])
    end

    it "renders comparison table with selected spaces" do
      space_a_value = "#{process_a.class.name}:#{process_a.id}"
      space_b_value = "#{process_b.class.name}:#{process_b.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_a_value, space_b_value])

      expect(page).to have_css("table.insights-table[data-heatmap]")

      within("thead") do
        expect(page).to have_content("Process Alpha")
        expect(page).to have_content("Process Beta")
        expect(page).to have_content("Row Total")
      end

      within("tbody") do
        expect(page).to have_content("21 to 30")
        expect(page).to have_content("51 to 60")
      end

      within("tfoot") do
        expect(page).to have_content("Column Total")
      end
    end

    it "shows heatmap styling on data cells" do
      space_a_value = "#{process_a.class.name}:#{process_a.id}"
      space_b_value = "#{process_b.class.name}:#{process_b.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_a_value, space_b_value])

      expect(page).to have_css("td.heatmap-cell--colored, td.heatmap-cell--gray")

      cell = find("td.insights-table__cell", text: /[1-9]/, match: :first)
      expect(cell[:style]).to match(/--i:/)
    end

    it "shows the legend" do
      space_a_value = "#{process_a.class.name}:#{process_a.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_a_value])

      within(".heatmap-legend") do
        expect(page).to have_content("Fewer")
        expect(page).to have_content("More")
      end
    end
  end

  context "when spaces are selected but have no data" do
    let!(:empty_process) { create(:participatory_process, :with_steps, organization:, title: { "en" => "Empty Process" }) }

    it "shows no-data message" do
      space_value = "#{empty_process.class.name}:#{empty_process.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value])

      expect(page).to have_content("No participation data found for the selected spaces")
      expect(page).to have_no_table
    end
  end

  context "when switching metrics" do
    let!(:process) { create(:participatory_process, :with_steps, organization:, title: { "en" => "Test Process" }) }
    let!(:component) { create(:proposal_component, :published, participatory_space: process) }
    let(:author) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }
    let!(:proposal) { create(:proposal, :published, component:, users: [author]) }

    before do
      create_list(:comment, 3, commentable: proposal, author:)
    end

    it "shows comments metric data when selected" do
      space_value = "#{process.class.name}:#{process.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value], metric: "comments")

      within("tfoot") do
        expect(page).to have_content("3")
      end
    end

    it "shows participants metric by default" do
      space_value = "#{process.class.name}:#{process.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value])

      within("tfoot") do
        expect(page).to have_content("1")
      end
    end
  end

  context "when switching axes via query params" do
    let!(:process) { create(:participatory_process, :with_steps, organization:, title: { "en" => "Axis Process" }) }
    let!(:component) { create(:proposal_component, :published, participatory_space: process) }
    let(:user_with_data) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s, "country" => "france" }) }

    before do
      create(:proposal, :published, component:, users: [user_with_data])
    end

    it "swaps rows and columns when params change" do
      space_value = "#{process.class.name}:#{process.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value], rows: "gender", cols: "age_span")

      within("thead") do
        expect(page).to have_content("21 to 30")
      end

      within("tbody") do
        expect(page).to have_content("Female")
      end
    end

    it "uses a different field when specified" do
      space_value = "#{process.class.name}:#{process.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value], rows: "gender", cols: "country")

      within("thead") do
        expect(page).to have_content("France")
      end

      within("tbody") do
        expect(page).to have_content("Female")
      end
    end
  end

  context "when query params are invalid" do
    let!(:process) { create(:participatory_process, :with_steps, organization:, title: { "en" => "Fallback Process" }) }
    let!(:component) { create(:proposal_component, :published, participatory_space: process) }
    let(:user_with_data) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }

    before do
      create(:proposal, :published, component:, users: [user_with_data])
    end

    it "falls back to defaults for invalid rows param" do
      space_value = "#{process.class.name}:#{process.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value], rows: "nonexistent_field")

      expect(page).to have_content("Comparative stats across spaces")
      within("tbody") do
        expect(page).to have_content("21 to 30")
      end
    end

    it "falls back to defaults for invalid metric param" do
      space_value = "#{process.class.name}:#{process.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value], metric: "fake_metric")

      expect(page).to have_content("Comparative stats across spaces")
      within("tfoot") do
        expect(page).to have_content("1")
      end
    end

    it "gracefully handles invalid space ID" do
      visit decidim_extra_user_fields.benchmarking_path(spaces: ["Decidim::ParticipatoryProcess:999999"])

      expect(page).to have_content("Select one or more participatory spaces to compare")
    end

    it "gracefully handles non-manifest class name" do
      visit decidim_extra_user_fields.benchmarking_path(spaces: ["Decidim::User:1"])

      expect(page).to have_content("Select one or more participatory spaces to compare")
    end

    it "gracefully handles malformed space keys" do
      visit decidim_extra_user_fields.benchmarking_path(spaces: [":1", "ClassName:", ""])

      expect(page).to have_content("Select one or more participatory spaces to compare")
    end
  end

  context "when export button is available" do
    let!(:process_a) { create(:participatory_process, :with_steps, organization:, title: { "en" => "Export Process" }) }
    let!(:component_a) { create(:proposal_component, :published, participatory_space: process_a) }
    let(:author) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }

    before do
      create(:proposal, :published, component: component_a, users: [author])
    end

    it "shows the Export button when data is present" do
      space_value = "#{process_a.class.name}:#{process_a.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value])

      within(".item_show__header") do
        expect(page).to have_content("Export")
      end
    end

    it "does not show the Export button when no spaces are selected" do
      visit decidim_extra_user_fields.benchmarking_path

      within(".item_show__header") do
        expect(page).to have_no_content("Export")
      end
    end

    it "shows flash notice when clicking export" do
      space_value = "#{process_a.class.name}:#{process_a.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value])

      within(".item_show__header") do
        click_on "Export"
      end

      click_on "Export CSV"

      expect(page).to have_content("Your export is currently in progress")
    end

    it "sends an export email with benchmarking in the subject" do
      space_value = "#{process_a.class.name}:#{process_a.id}"
      visit decidim_extra_user_fields.benchmarking_path(spaces: [space_value])

      within(".item_show__header") do
        click_on "Export"
      end

      perform_enqueued_jobs { click_on "Export CSV" }

      expect(last_email.subject).to include("benchmarking")
    end
  end

  context "when user is not admin" do
    let(:user) { create(:user, :confirmed, organization:) }

    it "cannot access the benchmarking page" do
      visit decidim_extra_user_fields.benchmarking_path
      expect(page).to have_no_content("Comparative stats across spaces")
    end
  end
end
