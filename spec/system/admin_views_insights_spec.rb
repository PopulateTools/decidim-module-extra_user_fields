# frozen_string_literal: true

require "spec_helper"

describe "Admin views insights" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "with a participatory process" do
    let!(:participatory_process) { create(:participatory_process, organization:) }

    context "when visiting the insights page" do
      before do
        visit decidim_admin_participatory_process_insights.root_path(
          participatory_process_slug: participatory_process.slug
        )
      end

      it "renders the sidebar menu with participatory space items" do
        within(".sidebar-menu") do
          expect(page).to have_content("Components")
          expect(page).to have_content("Insights")
        end
      end

      it "displays the page title" do
        expect(page).to have_content("Participatory Space Insights")
      end

      it "displays the description" do
        expect(page).to have_content("Explore participant activity across profile dimensions")
      end

      it "shows the selector dropdowns" do
        within(".insights-selectors") do
          expect(page).to have_content("Rows (Y axis)")
          expect(page).to have_content("Columns (X axis)")
          expect(page).to have_content("Metric")
          expect(page).to have_content("Gender")
          expect(page).to have_content("Age span")
          expect(page).to have_content("Participants")
        end
      end

      it "shows empty state when no participation data exists" do
        expect(page).to have_content("No participation data found")
      end
    end
  end

  context "with participation data in a process" do
    let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let!(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }

    let(:user_female_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }
    let(:user_male_young) { create(:user, :confirmed, organization:, extended_data: { "gender" => "male", "date_of_birth" => 28.years.ago.to_date.to_s }) }
    let(:user_no_data) { create(:user, :confirmed, organization:, extended_data: {}) }

    before do
      create(:proposal, :published, component: proposal_component, users: [user_female_young])
      create(:proposal, :published, component: proposal_component, users: [user_male_young])
      create(:proposal, :published, component: proposal_component, users: [user_no_data])
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug
      )
    end

    it "renders the pivot table headers" do
      # Default: rows=age_span, cols=gender
      within("thead") do
        expect(page).to have_content("Female")
        expect(page).to have_content("Male")
        expect(page).to have_content("Row Total")
      end
    end

    it "renders row labels in the pivot table" do
      # Default: rows=age_span, cols=gender
      within("tbody") do
        expect(page).to have_content("21 to 30")
        expect(page).to have_content("Not specified / Prefer not to say")
      end
    end

    it "renders the column totals and grand total" do
      within("tfoot") do
        expect(page).to have_content("Column Total")
        expect(page).to have_content("3")
      end
    end

    it "shows the legend" do
      within(".heatmap-legend") do
        expect(page).to have_content("Fewer")
        expect(page).to have_content("More")
      end
    end
  end

  context "when switching axes via query params" do
    let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let!(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user_with_data) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s, "country" => "france" }) }

    before do
      create(:proposal, :published, component: proposal_component, users: [user_with_data])
    end

    it "swaps rows and columns when params change" do
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug,
        rows: "gender",
        cols: "age_span"
      )

      within("thead") do
        expect(page).to have_content("21 to 30")
      end

      within("tbody") do
        expect(page).to have_content("Female")
      end
    end

    it "uses a different field when specified" do
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug,
        rows: "gender",
        cols: "country"
      )

      within("thead") do
        expect(page).to have_content("France")
      end

      within("tbody") do
        expect(page).to have_content("Female")
      end
    end
  end

  context "when switching metrics" do
    let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let!(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:author) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }
    let!(:proposal) { create(:proposal, :published, component: proposal_component, users: [author]) }

    before do
      create_list(:comment, 3, commentable: proposal, author: author)
    end

    it "shows comments metric data when selected" do
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug,
        metric: "comments"
      )

      within("tfoot") do
        expect(page).to have_content("3")
      end
    end

    it "shows participants metric by default" do
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug
      )

      within("tfoot") do
        expect(page).to have_content("1")
      end
    end
  end

  context "when cells have heatmap styling" do
    let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let!(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user_with_data) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }

    before do
      create(:proposal, :published, component: proposal_component, users: [user_with_data])
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug
      )
    end

    it "adds data-heatmap attribute to the table" do
      expect(page).to have_css("table.insights-table[data-heatmap]")
    end

    it "applies heatmap classes to data cells" do
      expect(page).to have_css("td.heatmap-cell--colored, td.heatmap-cell--gray")
    end

    it "applies inline heatmap style to data cells" do
      cell = find("td.insights-table__cell", text: /[1-9]/, match: :first)
      expect(cell[:style]).to match(/--i:/)
    end

    it "applies inline heatmap style to row total cells" do
      cell = find("td.heatmap-total.insights-table__row-total", text: /[1-9]/, match: :first)
      expect(cell[:style]).to match(/--i:/)
    end

    it "applies inline heatmap style to column total cells" do
      cell = find("td.heatmap-total.insights-table__col-total", match: :first)
      expect(cell[:style]).to match(/--i:/)
    end
  end

  context "when query params are invalid" do
    let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let!(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user_with_data) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }

    before do
      create(:proposal, :published, component: proposal_component, users: [user_with_data])
    end

    it "falls back to defaults for invalid rows param" do
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug,
        rows: "nonexistent_field"
      )

      expect(page).to have_content("Participatory Space Insights")
      # Default rows=age_span, so we see age span labels in tbody
      within("tbody") do
        expect(page).to have_content("21 to 30")
      end
    end

    it "falls back to defaults for invalid metric param" do
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug,
        metric: "fake_metric"
      )

      expect(page).to have_content("Participatory Space Insights")
      within("tfoot") do
        expect(page).to have_content("1")
      end
    end
  end

  context "with an assembly" do
    let!(:assembly) { create(:assembly, organization:) }

    it "renders the sidebar menu with assembly items" do
      visit decidim_admin_assembly_insights.root_path(assembly_slug: assembly.slug)

      within(".sidebar-menu") do
        expect(page).to have_content("Components")
        expect(page).to have_content("Insights")
      end

      expect(page).to have_content("Participatory Space Insights")
    end
  end

  context "when exporting insights" do
    let!(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let!(:proposal_component) { create(:proposal_component, :published, participatory_space: participatory_process) }
    let(:user_with_data) { create(:user, :confirmed, organization:, extended_data: { "gender" => "female", "date_of_birth" => 25.years.ago.to_date.to_s }) }

    before do
      create(:proposal, :published, component: proposal_component, users: [user_with_data])
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug
      )
    end

    it "shows the export dropdown button" do
      expect(page).to have_button("Export")
    end

    it "shows export format options in the dropdown" do
      click_on "Export"
      expect(page).to have_content("CSV")
      expect(page).to have_content("JSON")
      expect(page).to have_content("Excel")
    end

    it "triggers export and shows flash notice" do
      click_on "Export"
      perform_enqueued_jobs { click_on "CSV" }
      expect(page).to have_content("Your export is currently in progress")
    end

    it "sends an export email with insights in the subject" do
      click_on "Export"
      perform_enqueued_jobs { click_on "CSV" }
      expect(last_email.subject).to include("insights")
    end
  end

  context "when user is not admin" do
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let(:user) { create(:user, :confirmed, organization:) }

    it "cannot access the insights page" do
      visit decidim_admin_participatory_process_insights.root_path(
        participatory_process_slug: participatory_process.slug
      )
      expect(page).to have_no_content("Participatory Space Insights")
    end
  end
end
