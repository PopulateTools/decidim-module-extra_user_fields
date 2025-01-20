# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateRegistration do
      describe "call" do
        let(:organization) { create(:organization) }

        let(:name) { "Username" }
        let(:nickname) { "nickname" }
        let(:email) { "user@example.org" }
        let(:password) { "Y1fERVzL2F" }
        let(:tos_agreement) { "1" }
        let(:newsletter) { "1" }
        let(:current_locale) { "es" }
        let(:country) { "Argentina" }
        let(:date_of_birth) { "01/01/2000" }
        let(:gender) { "other" }
        let(:location) { "Paris" }
        let(:phone_number) { "0123456789" }
        let(:postal_code) { "75001" }
        let(:underage) { "0" }
        let(:statutory_representative_email) { nil }
        let(:extended_data) do
          {
            country:,
            date_of_birth:,
            gender:,
            location:,
            phone_number:,
            postal_code:,
            underage:,
            statutory_representative_email:
          }
        end

        let(:form_params) do
          {
            "user" => {
              "name" => name,
              "nickname" => nickname,
              "email" => email,
              "password" => password,
              "tos_agreement" => tos_agreement,
              "newsletter_at" => newsletter,
              "country" => country,
              "postal_code" => postal_code,
              "date_of_birth" => date_of_birth,
              "gender" => gender,
              "phone_number" => phone_number,
              "location" => location,
              "underage" => underage,
              "statutory_representative_email" => statutory_representative_email
            }
          }
        end
        let(:form) do
          RegistrationForm.from_params(
            form_params,
            current_locale:
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
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

          context "when the user was already invited" do
            let(:user) { build(:user, email:, organization:) }

            before do
              user.invite!
              clear_enqueued_jobs
            end

            it "receives the invitation email again" do
              expect { command.call }.not_to change(User, :count)
              expect do
                command.call
                user.reload
              end.to broadcast(:invalid)
                .and change(user.reload, :invitation_token)
              expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("mailers").twice
            end
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            expect(User).to receive(:create!).with(
              name: form.name,
              nickname: form.nickname,
              email: form.email,
              password: form.password,
              password_updated_at: an_instance_of(ActiveSupport::TimeWithZone),
              tos_agreement: form.tos_agreement,
              newsletter_notifications_at: form.newsletter_at,
              organization:,
              accepted_tos_version: organization.tos_version,
              locale: form.current_locale,
              extended_data: {
                country:,
                date_of_birth: Date.parse(date_of_birth),
                gender:,
                location:,
                phone_number:,
                postal_code:,
                underage:,
                statutory_representative_email:
              }
            ).and_call_original

            expect { command.call }.to change(User, :count).by(1)
          end

          it "sets the password_updated_at to the current time" do
            expect { command.call }.to broadcast(:ok)
            expect(User.last.password_updated_at).to be_between(2.seconds.ago, Time.current)
          end

          describe "when user keeps the newsletter unchecked" do
            let(:newsletter) { "0" }

            it "creates a user with no newsletter notifications" do
              expect do
                command.call
                expect(User.last.newsletter_notifications_at).to be_nil
              end.to change(User, :count).by(1)
            end
          end

          describe "when the user is underage and sends a valid email" do
            let(:underage) { "1" }
            let(:statutory_representative_email) { "user@example.fr" }

            it "creates a user with the statutory representative email and sends email" do
              expect do
                expect(Decidim::ExtraUserFields::StatutoryRepresentativeMailer).to receive(:inform).with(instance_of(Decidim::User)).and_call_original

                command.call

                user = User.last
                expect(user.extended_data["statutory_representative_email"]).to eq(statutory_representative_email)
              end.to change(User, :count).by(1)
            end
          end

          describe "when the user is underage and tries to duplicate email" do
            let(:underage) { "1" }
            let(:statutory_representative_email) { email }

            it "broadcasts invalid" do
              expect(Decidim::ExtraUserFields::StatutoryRepresentativeMailer).not_to receive(:inform).with(instance_of(Decidim::User)).and_call_original

              expect { command.call }.to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
