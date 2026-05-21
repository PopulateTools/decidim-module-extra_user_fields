# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization extra user fields" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "creates a new item in submenu" do
    visit decidim_admin.officializations_path

    within ".sidebar-menu" do
      expect(page).to have_content("Manage extra user fields")
    end
  end

  context "when accessing extra user fields" do
    before do
      visit decidim_extra_user_fields.root_path
    end

    it "displays the form" do
      within ".item_show__wrapper" do
        expect(page).to have_content("Manage extra user fields")
        expect(page).to have_css("#extra_user_fields")
      end
    end

    it "allows to enable extra user fields functionality" do
      within "#extra_user_fields" do
        expect(page).to have_content("Enable extra user fields")
        expect(page).to have_content("Available extra fields for signup form")
      end
    end

    it "displays enabled and required checkboxes for fields" do
      within "#accordion-setup" do
        country_row = find("input[name='extra_user_fields[country_enabled]']", visible: :hidden).ancestor("tr")
        within(country_row) do
          expect(page).to have_css("[data-field-state-target='enabled']")
          expect(page).to have_css("[data-field-state-target='required']")
        end

        expect(page).to have_field("extra_user_fields[underage_enabled]", type: "hidden", visible: :hidden)
      end
    end

    it "saves field state settings" do
      check("extra_user_fields[enabled]")

      within "#accordion-setup" do
        # Enable and require country
        country_row = find("input[name='extra_user_fields[country_enabled]']", visible: :hidden).ancestor("tr")
        within(country_row) do
          find("[data-field-state-target='enabled']").check
          find("[data-field-state-target='required']").check
        end

        # Enable gender (optional)
        gender_row = find("input[name='extra_user_fields[gender_enabled]']", visible: :hidden).ancestor("tr")
        within(gender_row) do
          find("[data-field-state-target='enabled']").check
        end
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")

      visit decidim_extra_user_fields.root_path

      within "#accordion-setup" do
        country_row = find("input[name='extra_user_fields[country_enabled]']", visible: :hidden).ancestor("tr")
        within(country_row) do
          expect(find("[data-field-state-target='enabled']")).to be_checked
          expect(find("[data-field-state-target='required']")).to be_checked
        end

        gender_row = find("input[name='extra_user_fields[gender_enabled]']", visible: :hidden).ancestor("tr")
        within(gender_row) do
          expect(find("[data-field-state-target='enabled']")).to be_checked
          expect(find("[data-field-state-target='required']")).not_to be_checked
        end
      end
    end

    context "when form is valid" do
      it "flashes a success message" do
        check("extra_user_fields[enabled]")

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end
    end

    context "when custom select_fields" do
      it "displays the custom select fields" do
        within "#accordion-extras" do
          expect(page).to have_content("Additional custom fields")
          expect(page).to have_content("Enable participant type")
          expect(page).to have_content("This field is a list of participant types")

          participant_row = find_by_id("extra_user_fields_select_field_participant_type", visible: :hidden).ancestor("tr")
          within(participant_row) do
            find("[data-field-state-target='enabled']").check
          end
        end

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end

      it "persists select field after save and reload" do
        within "#accordion-extras" do
          participant_row = find_by_id("extra_user_fields_select_field_participant_type", visible: :hidden).ancestor("tr")
          within(participant_row) do
            find("[data-field-state-target='enabled']").check
          end
        end

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")

        visit decidim_extra_user_fields.root_path

        within "#accordion-extras" do
          participant_row = find_by_id("extra_user_fields_select_field_participant_type", visible: :hidden).ancestor("tr")
          within(participant_row) do
            expect(find("[data-field-state-target='enabled']")).to be_checked
          end
        end
      end
    end

    context "when custom boolean_fields" do
      it "displays the custom boolean fields" do
        within "#accordion-extras" do
          expect(page).to have_content("Additional custom fields")
          expect(page).to have_content("Enable NGO field")
          expect(page).to have_content("This field is a Boolean field. User will be able to check if is a NGO")

          ngo_row = find_by_id("extra_user_fields_boolean_field_ngo", visible: :hidden).ancestor("tr")
          within(ngo_row) do
            find("[data-field-state-target='enabled']").check
          end
        end

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end
    end

    context "when enabling all custom field types together" do
      it "saves and restores all custom fields correctly" do
        within "#accordion-extras" do
          # Enable participant_type (select field)
          participant_row = find_by_id("extra_user_fields_select_field_participant_type", visible: :hidden).ancestor("tr")
          within(participant_row) do
            find("[data-field-state-target='enabled']").check
          end

          # Enable ngo (boolean field)
          ngo_row = find_by_id("extra_user_fields_boolean_field_ngo", visible: :hidden).ancestor("tr")
          within(ngo_row) do
            find("[data-field-state-target='enabled']").check
          end

          # Enable motto (text field)
          motto_row = find_by_id("extra_user_fields_text_field_motto", visible: :hidden).ancestor("tr")
          within(motto_row) do
            find("[data-field-state-target='enabled']").check
          end
        end

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")

        visit decidim_extra_user_fields.root_path

        within "#accordion-extras" do
          participant_row = find_by_id("extra_user_fields_select_field_participant_type", visible: :hidden).ancestor("tr")
          within(participant_row) do
            expect(find("[data-field-state-target='enabled']")).to be_checked
          end

          ngo_row = find_by_id("extra_user_fields_boolean_field_ngo", visible: :hidden).ancestor("tr")
          within(ngo_row) do
            expect(find("[data-field-state-target='enabled']")).to be_checked
          end

          motto_row = find_by_id("extra_user_fields_text_field_motto", visible: :hidden).ancestor("tr")
          within(motto_row) do
            expect(find("[data-field-state-target='enabled']")).to be_checked
          end
        end
      end
    end

    context "when custom text_fields" do
      it "displays the custom text fields" do
        within "#accordion-extras" do
          expect(page).to have_content("Additional custom fields")
          expect(page).to have_content('Enable "My Motto" field')
          expect(page).to have_content("This field is a String field. If checked, user can fill in a personal phrase or motto")

          motto_row = find_by_id("extra_user_fields_text_field_motto", visible: :hidden).ancestor("tr")
          within(motto_row) do
            find("[data-field-state-target='enabled']").check
          end
        end

        find("*[type=submit]", text: "Save configuration").click
        expect(page).to have_content("Extra user fields correctly updated in organization")
      end
    end
  end

  context "when phone number config is set" do
    before do
      visit decidim_extra_user_fields.root_path
    end

    it "persists pattern and placeholder after save and reload" do
      check("extra_user_fields[enabled]")

      within "#accordion-setup" do
        phone_row = find("input[name='extra_user_fields[phone_number_enabled]']", visible: :hidden).ancestor("tbody")
        within(phone_row) do
          find("[data-field-state-target='enabled']").check
          fill_in "extra_user_fields[phone_number_pattern]", with: "^\\+34[0-9]{9}$"
          fill_in "extra_user_fields[phone_number_placeholder_en]", with: "+34600000000"
        end
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")

      visit decidim_extra_user_fields.root_path

      within "#accordion-setup" do
        phone_row = find("input[name='extra_user_fields[phone_number_enabled]']", visible: :hidden).ancestor("tbody")
        within(phone_row) do
          expect(find("[data-field-state-target='enabled']")).to be_checked
          expect(page).to have_field("extra_user_fields[phone_number_pattern]", with: "^\\+34[0-9]{9}$")
          expect(page).to have_field("extra_user_fields[phone_number_placeholder_en]", with: "+34600000000")
        end
      end
    end
  end

  context "when underage config is set" do
    before do
      visit decidim_extra_user_fields.root_path
    end

    it "persists underage limit after save and reload" do
      check("extra_user_fields[enabled]")

      within "#accordion-setup" do
        underage_tbody = find("input[name='extra_user_fields[underage_enabled]']", visible: :hidden).ancestor("tbody")
        within(underage_tbody) do
          find("[data-field-state-target='enabled']").check
          select "16", from: "extra_user_fields[underage_limit]"
        end
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")

      visit decidim_extra_user_fields.root_path

      within "#accordion-setup" do
        underage_tbody = find("input[name='extra_user_fields[underage_enabled]']", visible: :hidden).ancestor("tbody")
        within(underage_tbody) do
          expect(find("[data-field-state-target='enabled']")).to be_checked
          expect(page).to have_select("extra_user_fields[underage_limit]", selected: "16")
        end
      end
    end
  end

  context "when disabling a previously enabled field" do
    before do
      visit decidim_extra_user_fields.root_path
    end

    it "persists disabled state after save and reload" do
      check("extra_user_fields[enabled]")

      # First enable country
      within "#accordion-setup" do
        country_row = find("input[name='extra_user_fields[country_enabled]']", visible: :hidden).ancestor("tr")
        within(country_row) do
          find("[data-field-state-target='enabled']").check
        end
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")

      visit decidim_extra_user_fields.root_path

      # Verify it's enabled
      within "#accordion-setup" do
        country_row = find("input[name='extra_user_fields[country_enabled]']", visible: :hidden).ancestor("tr")
        within(country_row) do
          expect(find("[data-field-state-target='enabled']")).to be_checked
        end
      end

      # Now disable it
      within "#accordion-setup" do
        country_row = find("input[name='extra_user_fields[country_enabled]']", visible: :hidden).ancestor("tr")
        within(country_row) do
          find("[data-field-state-target='enabled']").uncheck
        end
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")

      visit decidim_extra_user_fields.root_path

      # Verify it's now disabled
      within "#accordion-setup" do
        country_row = find("input[name='extra_user_fields[country_enabled]']", visible: :hidden).ancestor("tr")
        within(country_row) do
          expect(find("[data-field-state-target='enabled']")).not_to be_checked
        end
      end
    end
  end

  context "and no translations are provided" do
    let(:custom_select_fields) { { animal_type: { dog: "I love dogs", cat: "I love cats" } } }
    let(:custom_boolean_fields) { [:dog_person] }
    let(:custom_text_fields) { [:pet_name] }

    before do
      allow(Decidim::ExtraUserFields).to receive(:select_fields).and_return(custom_select_fields)
      allow(Decidim::ExtraUserFields).to receive(:boolean_fields).and_return(custom_boolean_fields)
      allow(Decidim::ExtraUserFields).to receive(:text_fields).and_return(custom_text_fields)
      visit decidim_extra_user_fields.root_path
    end

    it "displays the custom select fields" do
      within "#accordion-extras" do
        expect(page).to have_content("Additional custom fields")
        expect(page).to have_content("Animal type")

        animal_row = find_by_id("extra_user_fields_select_field_animal_type", visible: :hidden).ancestor("tr")
        within(animal_row) do
          find("[data-field-state-target='enabled']").check
        end
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")
    end

    it "displays the custom boolean fields" do
      within "#accordion-extras" do
        expect(page).to have_content("Additional custom fields")
        expect(page).to have_content("Dog person")

        dog_row = find_by_id("extra_user_fields_boolean_field_dog_person", visible: :hidden).ancestor("tr")
        within(dog_row) do
          find("[data-field-state-target='enabled']").check
        end
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")
    end

    it "displays the custom text fields" do
      within "#accordion-extras" do
        expect(page).to have_content("Additional custom fields")
        expect(page).to have_content("Pet name")

        pet_row = find_by_id("extra_user_fields_text_field_pet_name", visible: :hidden).ancestor("tr")
        within(pet_row) do
          find("[data-field-state-target='enabled']").check
        end
      end

      find("*[type=submit]", text: "Save configuration").click
      expect(page).to have_content("Extra user fields correctly updated in organization")
    end
  end
end
