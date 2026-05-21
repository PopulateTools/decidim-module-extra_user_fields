# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateOmniauthRegistration do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:email) { "user@from-facebook.com" }
        let(:provider) { "facebook" }
        let(:uid) { "12345" }
        let(:oauth_signature) { OmniauthRegistrationForm.create_signature(provider, uid) }
        let(:verified_email) { email }
        let(:tos_agreement) { true }
        let(:country) { "Argentina" }
        let(:date_of_birth) { "01/01/2000" }
        let(:gender) { "other" }
        let(:age_range) { "17_to_30" }
        let(:location) { "Paris" }
        let(:phone_number) { "0123456789" }
        let(:postal_code) { "75001" }
        let(:underage) { false }
        let(:select_fields) do
          {
            "participant_type" => "individual"
          }
        end
        let(:boolean_fields) do
          ["ngo"]
        end
        let(:text_fields) do
          {
            "motto" => "I think, therefore I am"
          }
        end
        let(:statutory_representative_email) { nil }
        let(:extended_data) do
          {
            country:,
            date_of_birth:,
            gender:,
            age_range:,
            location:,
            phone_number:,
            postal_code:,
            underage:,
            select_fields:,
            boolean_fields:,
            text_fields:,
            statutory_representative_email:
          }
        end

        let(:form_params) do
          {
            "user" => {
              "provider" => provider,
              "uid" => uid,
              "email" => email,
              "email_verified" => true,
              "name" => "Facebook User",
              "nickname" => "facebook_user",
              "oauth_signature" => oauth_signature,
              "avatar_url" => "http://www.example.com/foo.jpg",
              "tos_agreement" => tos_agreement,
              "country" => country,
              "postal_code" => postal_code,
              "date_of_birth" => date_of_birth,
              "gender" => gender,
              "age_range" => age_range,
              "phone_number" => phone_number,
              "location" => location,
              "underage" => underage,
              "select_fields" => select_fields,
              "boolean_fields" => boolean_fields,
              "text_fields" => text_fields,
              "statutory_representative_email" => statutory_representative_email
            }
          }
        end
        let(:form) do
          OmniauthRegistrationForm.from_params(
            form_params
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form, verified_email) }

        before do
          stub_request(:get, "http://www.example.com/foo.jpg")
            .to_return(status: 200, body: File.read("spec/assets/avatar.jpg"), headers: { "Content-Type" => "image/jpeg" })
        end

        describe "when the form oauth_signature cannot ve verified" do
          let(:oauth_signature) { "1234" }

          it "raises a InvalidOauthSignature exception" do
            expect { command.call }.to raise_error InvalidOauthSignature
          end
        end

        context "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a user" do
            expect do
              command.call
            end.not_to change(User, :count)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            allow(SecureRandom).to receive(:hex).and_return("decidim123456789")

            expect do
              command.call
            end.to change(User, :count).by(1)

            user = User.find_by(email: form.email)
            expect(user.encrypted_password).not_to be_nil
            expect(user.email).to eq(form.email)
            expect(user.organization).to eq(organization)
            expect(user.newsletter_notifications_at).to be_nil
            expect(user).to be_confirmed
            expect(user.valid_password?("decidim123456789")).to be(true)

            expect(user.extended_data["country"]).to eq(country)
            expect(user.extended_data["postal_code"]).to eq(postal_code)
            expect(user.extended_data["date_of_birth"]).to eq(date_of_birth.to_date.iso8601)
            expect(user.extended_data["gender"]).to eq(gender)
            expect(user.extended_data["age_range"]).to eq(age_range)
            expect(user.extended_data["phone_number"]).to eq(phone_number)
            expect(user.extended_data["location"]).to eq(location)
            expect(user.extended_data["underage"]).to eq(underage)
            expect(user.extended_data["select_fields"]).to eq(select_fields)
            expect(user.extended_data["boolean_fields"]).to eq(boolean_fields)
            expect(user.extended_data["text_fields"]).to eq(text_fields)
          end

          # NOTE: This is important so that the users who are only
          # authenticating using omniauth will not need to update their
          # passwords.
          it "leaves password_updated_at nil" do
            expect { command.call }.to broadcast(:ok)

            user = User.find_by(email: form.email)
            expect(user.password_updated_at).to be_nil
          end

          context "when notifying about registration with oauth data" do
            let(:identity) { Decidim::Identity.new(id: 1234) }

            before do
              allow(command).to receive(:create_identity).and_return(identity)
            end

            context "when the user is already confirmed" do
              it "publishes the omniauth registration event" do
                user = create(:user, :confirmed, email:, organization:)
                expect(ActiveSupport::Notifications)
                  .to receive(:publish)
                  .with(
                    "decidim.user.omniauth_registration",
                    user_id: user.id,
                    identity_id: 1234,
                    provider:,
                    uid:,
                    email:,
                    name: "Facebook User",
                    nickname: "facebook_user",
                    avatar_url: "http://www.example.com/foo.jpg",
                    raw_data: {},
                    tos_agreement: true,
                    accepted_tos_version: user.accepted_tos_version,
                    newsletter_notifications_at: user.newsletter_notifications_at
                  )
                command.call
              end
            end

            context "when the user is not confirmed" do
              it "confirms the user and publishes the omniauth registration event" do
                user = create(:user, email:, organization:)
                allow(ActiveSupport::Notifications).to receive(:publish).and_call_original
                expect(ActiveSupport::Notifications)
                  .to receive(:publish)
                  .with("decidim.user.omniauth_registration", hash_including(user_id: user.id))
                command.call
                expect(user.reload).to be_confirmed
              end
            end
          end

          describe "user linking" do
            context "with a verified email" do
              let(:verified_email) { email }

              it "links a previously existing user" do
                user = create(:user, email:, organization:)
                expect { command.call }.not_to change(User, :count)
                expect(user.identities.length).to eq(1)
              end

              it "confirms a previously existing user" do
                create(:user, email:, organization:)
                expect { command.call }.not_to change(User, :count)

                user = User.find_by(email:)
                expect(user).to be_confirmed
              end
            end

            context "with an unverified email" do
              let(:verified_email) { nil }

              it "doesn't link a previously existing user" do
                user = create(:user, email:, organization:)
                expect { command.call }.to broadcast(:error)

                expect(user.identities.length).to eq(0)
              end

              it "doesn't confirm a previously existing user" do
                create(:user, email:, organization:)
                expect { command.call }.to broadcast(:error)

                user = User.find_by(email:)
                expect(user).not_to be_confirmed
              end
            end
          end

          it "creates a new identity" do
            expect do
              command.call
            end.to change(Identity, :count).by(1)
            last_identity = Identity.last
            expect(last_identity.provider).to eq(form.provider)
            expect(last_identity.uid).to eq(form.uid)
            expect(last_identity.organization).to eq(organization)
          end

          it "confirms the user if the email is already verified" do
            # rubocop:disable RSpec/AnyInstance
            expect_any_instance_of(User).to receive(:skip_confirmation!)
            # rubocop:enable RSpec/AnyInstance
            command.call
          end
        end

        context "when a user exists with that identity" do
          before do
            user = create(:user, email:, organization:)
            create(:identity, user:, provider:, uid:)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          context "with the same email as reported by the identity" do
            it "confirms the user" do
              command.call

              user = User.find_by(email:)
              expect(user).to be_confirmed
            end
          end

          context "with another email than in the one reported by the identity" do
            let(:verified_email) { "other@email.com" }

            it "doesn't confirm the user" do
              command.call

              user = User.find_by(email:)
              expect(user).not_to be_confirmed
            end
          end

          context "when the user is underage and tries to duplicate email" do
            let(:underage) { true }
            let(:statutory_representative_email) { email }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
