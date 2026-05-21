# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Organization do
    subject(:organization) { build(:organization, extra_user_fields:) }

    let(:extra_user_fields) { { "enabled" => extra_user_field, "date_of_birth" => date_of_birth } }
    let(:extra_user_field) { true }
    let(:date_of_birth) { { "enabled" => true, "required" => false } }
    let(:omniauth_secrets) do
      {
        facebook: {
          enabled: true,
          app_id: "fake-facebook-app-id",
          app_secret: "fake-facebook-app-secret"
        },
        twitter: {
          enabled: true,
          api_key: "fake-twitter-api-key",
          api_secret: "fake-twitter-api-secret"
        },
        google_oauth2: {
          enabled: true,
          client_id: nil,
          client_secret: nil
        },
        test: {
          enabled: true,
          icon: "tools-line"
        }
      }
    end

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::OrganizationPresenter
    end

    describe "has an association for scopes" do
      subject(:organization_scopes) { organization.scopes }

      let(:scopes) { create_list(:scope, 2, organization:) }

      it { is_expected.to match_array(scopes) }
    end

    describe "has an association for scope types" do
      subject(:organization_scopes_types) { organization.scope_types }

      let(:scope_types) { create_list(:scope_type, 2, organization:) }

      it { is_expected.to match_array(scope_types) }
    end

    describe "validations" do
      it "default locale should be included in available locales" do
        subject.available_locales = [:ca, :es]
        subject.default_locale = :en
        expect(subject).not_to be_valid
      end
    end

    describe "enabled omniauth providers" do
      subject(:enabled_providers) { organization.enabled_omniauth_providers }

      let!(:previous_omniauth_providers) { Decidim.omniauth_providers }

      after do
        Decidim.omniauth_providers = previous_omniauth_providers
      end

      context "when omniauth_settings are nil" do
        context "when providers are enabled" do
          before do
            allow(Decidim).to receive(:omniauth_providers).and_return(omniauth_secrets)
          end

          it "returns providers enabled" do
            expect(enabled_providers).to eq(omniauth_secrets)
          end
        end

        context "when providers are not enabled" do
          before do
            allow(Decidim).to receive(:omniauth_providers).and_return({})
          end

          it "returns no providers" do
            expect(enabled_providers).to be_empty
          end
        end
      end

      context "when it's overriden" do
        let(:organization) { create(:organization) }
        let(:omniauth_settings) do
          {
            "omniauth_settings_facebook_enabled" => true,
            "omniauth_settings_facebook_app_id" => Decidim::AttributeEncryptor.encrypt("overriden-app-id"),
            "omniauth_settings_facebook_app_secret" => Decidim::AttributeEncryptor.encrypt("overriden-app-secret"),
            "omniauth_settings_google_oauth2_enabled" => true,
            "omniauth_settings_google_oauth2_client_id" => Decidim::AttributeEncryptor.encrypt("overriden-client-id"),
            "omniauth_settings_google_oauth2_client_secret" => Decidim::AttributeEncryptor.encrypt("overriden-client-secret"),
            "omniauth_settings_twitter_enabled" => false
          }
        end

        before { organization.update!(omniauth_settings:) }

        it "returns only the enabled settings" do
          expect(subject[:facebook][:app_id]).to eq("overriden-app-id")
          expect(subject[:twitter]).to be_nil
          expect(subject[:google_oauth2][:client_id]).to eq("overriden-client-id")
        end
      end
    end

    describe "#static_pages_accessible_for" do
      it_behaves_like "accessible static pages" do
        let(:actual_page_ids) do
          organization.static_pages_accessible_for(user).pluck(:id)
        end
      end
    end

    describe "#extra_user_fields_enabled?" do
      it "returns true" do
        expect(subject).to be_extra_user_fields_enabled
      end

      context "when extra user fields are disabled" do
        let(:extra_user_field) { false }

        it "returns true" do
          expect(subject).not_to be_extra_user_fields_enabled
        end
      end
    end

    describe "#has_required_extra_user_fields?" do
      context "when a standard field is required" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => true, "required" => true }
          }
        end

        it "returns true" do
          expect(subject).to have_required_extra_user_fields
        end
      end

      context "when all fields are optional" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => true, "required" => false }
          }
        end

        it "returns false" do
          expect(subject).not_to have_required_extra_user_fields
        end
      end

      context "when all fields are disabled" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false }
          }
        end

        it "returns false" do
          expect(subject).not_to have_required_extra_user_fields
        end
      end

      context "when extra user fields are disabled globally" do
        let(:extra_user_fields) do
          {
            "enabled" => false,
            "date_of_birth" => { "enabled" => true, "required" => true }
          }
        end

        it "returns false" do
          expect(subject).not_to have_required_extra_user_fields
        end
      end

      context "when a select field is required" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } }
          }
        end

        it "returns true" do
          expect(subject).to have_required_extra_user_fields
        end
      end

      context "when a text field is required" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "text_fields" => { "motto" => { "enabled" => true, "required" => true } }
          }
        end

        it "returns true" do
          expect(subject).to have_required_extra_user_fields
        end
      end

      context "when collection fields are optional" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "select_fields" => { "participant_type" => { "enabled" => true, "required" => false } },
            "text_fields" => { "motto" => { "enabled" => true, "required" => false } }
          }
        end

        it "returns false" do
          expect(subject).not_to have_required_extra_user_fields
        end
      end
    end

    describe "#required_extra_field?" do
      context "when field is required" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "country" => { "enabled" => true, "required" => true }
          }
        end

        it "returns true" do
          expect(subject.required_extra_field?(:country)).to be true
        end
      end

      context "when field is optional" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "country" => { "enabled" => true, "required" => false }
          }
        end

        it "returns false" do
          expect(subject.required_extra_field?(:country)).to be false
        end
      end
    end

    describe "#extra_user_fields_complete?" do
      let(:user) { build(:user, organization:, extended_data:) }
      let(:extra_user_fields) do
        {
          "enabled" => true,
          "date_of_birth" => { "enabled" => true, "required" => true },
          "country" => { "enabled" => true, "required" => true },
          "gender" => { "enabled" => false, "required" => false }
        }
      end

      context "when all required fields are filled in" do
        let(:extended_data) { { "date_of_birth" => "2000-01-01", "country" => "ES" } }

        it "returns true" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when a required field is missing" do
        let(:extended_data) { { "date_of_birth" => "2000-01-01" } }

        it "returns false" do
          expect(subject.extra_user_fields_complete?(user)).to be false
        end
      end

      context "when an optional field is missing" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => true, "required" => true },
            "country" => { "enabled" => true, "required" => false }
          }
        end
        let(:extended_data) { { "date_of_birth" => "2000-01-01" } }

        it "returns true because optional fields are not enforced" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when a disabled field is missing" do
        let(:extended_data) { { "date_of_birth" => "2000-01-01", "country" => "ES" } }

        it "returns true even without gender" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when no fields are required" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false },
            "country" => { "enabled" => true, "required" => false }
          }
        end
        let(:extended_data) { {} }

        it "returns true" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when select_fields are activated" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false },
            "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } }
          }
        end

        context "when user has filled the select field" do
          let(:extended_data) { { "select_fields" => { "participant_type" => "individual" } } }

          it "returns true" do
            expect(subject.extra_user_fields_complete?(user)).to be true
          end
        end

        context "when user has not filled the select field" do
          let(:extended_data) { { "select_fields" => {} } }

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end

        context "when user has no select_fields data at all" do
          let(:extended_data) { {} }

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end
      end

      context "when text_fields are activated" do
        context "when text field is required" do
          let(:extra_user_fields) do
            {
              "enabled" => true,
              "date_of_birth" => { "enabled" => false, "required" => false },
              "text_fields" => { "motto" => { "enabled" => true, "required" => true } }
            }
          end

          context "when user has filled the text field" do
            let(:extended_data) { { "text_fields" => { "motto" => "Carpe diem" } } }

            it "returns true" do
              expect(subject.extra_user_fields_complete?(user)).to be true
            end
          end

          context "when user has not filled the text field" do
            let(:extended_data) { { "text_fields" => {} } }

            it "returns false" do
              expect(subject.extra_user_fields_complete?(user)).to be false
            end
          end

          context "when user has no text_fields data at all" do
            let(:extended_data) { {} }

            it "returns false" do
              expect(subject.extra_user_fields_complete?(user)).to be false
            end
          end
        end

        context "when text field is optional" do
          let(:extra_user_fields) do
            {
              "enabled" => true,
              "date_of_birth" => { "enabled" => false, "required" => false },
              "text_fields" => { "motto" => { "enabled" => true, "required" => false } }
            }
          end

          context "when user has not filled the text field" do
            let(:extended_data) { { "text_fields" => {} } }

            it "returns true" do
              expect(subject.extra_user_fields_complete?(user)).to be true
            end
          end

          context "when user has no text_fields data at all" do
            let(:extended_data) { {} }

            it "returns true" do
              expect(subject.extra_user_fields_complete?(user)).to be true
            end
          end
        end
      end

      context "when boolean_fields are activated" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false },
            "boolean_fields" => ["ngo"]
          }
        end
        let(:extended_data) { {} }

        it "returns true because boolean fields do not block completion" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when both standard and collection fields are activated" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "country" => { "enabled" => true, "required" => true },
            "date_of_birth" => { "enabled" => false, "required" => false },
            "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } },
            "text_fields" => { "motto" => { "enabled" => true, "required" => true } }
          }
        end

        context "when all fields are filled" do
          let(:extended_data) do
            {
              "country" => "FR",
              "select_fields" => { "participant_type" => "individual" },
              "text_fields" => { "motto" => "Carpe diem" }
            }
          end

          it "returns true" do
            expect(subject.extra_user_fields_complete?(user)).to be true
          end
        end

        context "when standard field is missing" do
          let(:extended_data) do
            {
              "select_fields" => { "participant_type" => "individual" },
              "text_fields" => { "motto" => "Carpe diem" }
            }
          end

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end

        context "when select field is missing" do
          let(:extended_data) do
            {
              "country" => "FR",
              "select_fields" => {},
              "text_fields" => { "motto" => "Carpe diem" }
            }
          end

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end

        context "when required text field is missing" do
          let(:extended_data) do
            {
              "country" => "FR",
              "select_fields" => { "participant_type" => "individual" },
              "text_fields" => {}
            }
          end

          it "returns false" do
            expect(subject.extra_user_fields_complete?(user)).to be false
          end
        end

        context "when optional text field is missing" do
          let(:extra_user_fields) do
            {
              "enabled" => true,
              "country" => { "enabled" => true, "required" => true },
              "date_of_birth" => { "enabled" => false, "required" => false },
              "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } },
              "text_fields" => { "motto" => { "enabled" => true, "required" => false } }
            }
          end
          let(:extended_data) do
            {
              "country" => "FR",
              "select_fields" => { "participant_type" => "individual" },
              "text_fields" => {}
            }
          end

          it "returns true" do
            expect(subject.extra_user_fields_complete?(user)).to be true
          end
        end
      end
    end

    describe "#collection_field_required?" do
      context "when collection field is required (Hash format)" do
        let(:extra_user_fields) { { "enabled" => true, "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } } } }

        it "returns true" do
          expect(subject.collection_field_required?(:select_fields, :participant_type)).to be true
        end
      end

      context "when collection field is optional (Hash format)" do
        let(:extra_user_fields) { { "enabled" => true, "select_fields" => { "participant_type" => { "enabled" => true, "required" => false } } } }

        it "returns false" do
          expect(subject.collection_field_required?(:select_fields, :participant_type)).to be false
        end
      end

      context "when collection is absent" do
        let(:extra_user_fields) { { "enabled" => true } }

        it "returns false" do
          expect(subject.collection_field_required?(:select_fields, :participant_type)).to be false
        end
      end
    end

    describe "#extra_user_field_configuration" do
      context "when field is activated with extra config" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "phone_number" => { "enabled" => true, "required" => false, "pattern" => "^\\+33", "placeholder" => "+33..." }
          }
        end

        it "returns config hash without the enabled/required keys" do
          config = subject.extra_user_field_configuration(:phone_number)
          expect(config).to eq({ "pattern" => "^\\+33", "placeholder" => "+33..." })
          expect(config).not_to have_key("enabled")
          expect(config).not_to have_key("required")
        end
      end

      context "when field is disabled" do
        let(:extra_user_fields) { { "enabled" => true, "country" => { "enabled" => false, "required" => false } } }

        it "returns empty hash" do
          expect(subject.extra_user_field_configuration(:country)).to eq({})
        end
      end

      context "when field is a collection (Hash format)" do
        let(:extra_user_fields) { { "enabled" => true, "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } } } }

        it "returns the collection hash" do
          expect(subject.extra_user_field_configuration(:select_fields)).to eq({ "participant_type" => { "enabled" => true, "required" => true } })
        end
      end

      context "when field does not exist" do
        let(:extra_user_fields) { { "enabled" => true } }

        it "returns empty hash" do
          expect(subject.extra_user_field_configuration(:nonexistent)).to eq({})
        end
      end
    end

    describe "#age_limit" do
      context "when underage_limit is set" do
        let(:extra_user_fields) { { "enabled" => true, "underage" => { "enabled" => true, "required" => false, "limit" => 16 } } }

        it "returns the integer value" do
          expect(subject.age_limit).to eq(16)
        end
      end

      context "when underage_limit is not set" do
        let(:extra_user_fields) { { "enabled" => true, "underage" => { "enabled" => true, "required" => false } } }

        it "returns 0" do
          expect(subject.age_limit).to eq(0)
        end
      end
    end

    describe "#extra_user_fields_complete? with Hash-format collection fields" do
      let(:user) { build(:user, organization:, extended_data:) }

      context "when a required select field is filled (Hash format)" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false },
            "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } }
          }
        end
        let(:extended_data) { { "select_fields" => { "participant_type" => "individual" } } }

        it "returns true" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when a required select field is missing (Hash format)" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false },
            "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } }
          }
        end
        let(:extended_data) { { "select_fields" => {} } }

        it "returns false" do
          expect(subject.extra_user_fields_complete?(user)).to be false
        end
      end

      context "when a required text field is filled (Hash format)" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false },
            "text_fields" => { "motto" => { "enabled" => true, "required" => true } }
          }
        end
        let(:extended_data) { { "text_fields" => { "motto" => "Carpe diem" } } }

        it "returns true" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end

      context "when a required text field is missing (Hash format)" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false },
            "text_fields" => { "motto" => { "enabled" => true, "required" => true } }
          }
        end
        let(:extended_data) { { "text_fields" => {} } }

        it "returns false" do
          expect(subject.extra_user_fields_complete?(user)).to be false
        end
      end

      context "when an optional collection field is missing (Hash format)" do
        let(:extra_user_fields) do
          {
            "enabled" => true,
            "date_of_birth" => { "enabled" => false, "required" => false },
            "select_fields" => { "participant_type" => { "enabled" => true, "required" => false } }
          }
        end
        let(:extended_data) { {} }

        it "returns true" do
          expect(subject.extra_user_fields_complete?(user)).to be true
        end
      end
    end

    describe "#activated_extra_field?" do
      it "returns true for legacy boolean enabled" do
        expect(subject).to be_activated_extra_field(:date_of_birth)
      end

      context "when given key doesn't exist in hash" do
        it "returns false" do
          expect(subject).not_to be_activated_extra_field(:unknown)
        end
      end

      context "when value for given key is nil" do
        let(:date_of_birth) { nil }

        it "returns false" do
          expect(subject).not_to be_activated_extra_field(:date_of_birth)
        end
      end

      context "when field is disabled" do
        let(:date_of_birth) { { "enabled" => false, "required" => false } }

        it "returns false" do
          expect(subject).not_to be_activated_extra_field(:date_of_birth)
        end
      end

      context "when field is optional" do
        let(:date_of_birth) { { "enabled" => true, "required" => false } }

        it "returns true" do
          expect(subject).to be_activated_extra_field(:date_of_birth)
        end
      end

      context "when field is required" do
        let(:date_of_birth) { { "enabled" => true, "required" => true } }

        it "returns true" do
          expect(subject).to be_activated_extra_field(:date_of_birth)
        end
      end
    end
  end
end
