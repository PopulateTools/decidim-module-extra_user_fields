# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AccountForm do
    subject do
      described_class.new(
        name:,
        email:,
        nickname:,
        password:,
        password_confirmation:,
        avatar:,
        remove_avatar:,
        personal_url:,
        about:,
        locale: "es",
        country:,
        postal_code:,
        date_of_birth:,
        gender:,
        phone_number:,
        location:
      ).with_context(
        current_organization: organization,
        current_user: user
      )
    end

    let(:user) { create(:user) }
    let(:organization) { user.organization }

    let(:name) { "Lord of the Foo" }
    let(:email) { "depths@ofthe.bar" }
    let(:nickname) { "foo_bar" }
    let(:password) { "Rf9kWTqQfyqkwseH" }
    let(:password_confirmation) { password }
    let(:avatar) { upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")) }
    let(:remove_avatar) { false }
    let(:personal_url) { "http://example.org" }
    let(:about) { "This is a description about me" }
    let(:country) { "Argentina" }
    let(:date_of_birth) { "01/01/2000" }
    let(:gender) { "Other" }
    let(:location) { "Paris" }
    let(:phone_number) { "0123456789" }
    let(:postal_code) { "75001" }

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with an empty name" do
      let(:name) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    describe "name" do
      context "with an empty name" do
        let(:name) { "" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "with invalid characters" do
        let(:name) { "foo@bar" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end

    describe "email" do
      context "with an empty email" do
        let(:email) { "" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when it's already in use in the same organization" do
        context "and belongs to a user" do
          let!(:existing_user) { create(:user, email:, organization:) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "and belongs to a group" do
          let!(:existing_group) { create(:user_group, email:, organization:) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end
      end

      context "when it's already in use in another organization" do
        let!(:existing_user) { create(:user, email:) }

        it "is valid" do
          expect(subject).to be_valid
        end
      end
    end

    describe "nickname" do
      context "with an empty nickname" do
        let(:nickname) { "" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when it's already in use in the same organization" do
        context "and belongs to a user" do
          let!(:existing_user) { create(:user, nickname:, organization:) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "and belongs to a group" do
          let!(:existing_group) { create(:user_group, nickname:, organization:) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end
      end

      context "when it's already in use in another organization" do
        let!(:existing_user) { create(:user, nickname:) }

        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "with invalid characters" do
        let(:nickname) { "foo@bar" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end

    describe "password" do
      context "when the password is weak" do
        let(:password) { "aaaabbbbcccc" }

        it { is_expected.not_to be_valid }
      end
    end

    describe "personal_url" do
      context "when it doesn't start with http" do
        let(:personal_url) { "example.org" }

        it "adds it" do
          expect(subject.personal_url).to eq("http://example.org")
        end
      end

      context "when it's not a valid URL" do
        let(:personal_url) { "foobar, aa" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
