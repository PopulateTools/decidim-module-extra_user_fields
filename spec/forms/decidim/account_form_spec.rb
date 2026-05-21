# frozen_string_literal: true

require "spec_helper"

module Decidim
  include ActiveStorage::Blob::Analyzable

  describe AccountForm do
    subject do
      described_class.new(
        name:,
        email:,
        nickname:,
        password:,
        old_password:,
        avatar:,
        remove_avatar:,
        personal_url:,
        about:,
        locale: "es",
        country:,
        postal_code:,
        date_of_birth:,
        gender:,
        age_range:,
        phone_number:,
        location:,
        underage:,
        select_fields:,
        boolean_fields:,
        text_fields:,
        statutory_representative_email:
      ).with_context(
        current_organization: organization,
        current_user: user
      )
    end

    let(:user) { create(:user, password: user_password, organization:) }
    let(:organization) { create(:organization, extra_user_fields:) }
    let(:extra_user_fields) do
      {
        "enabled" => true,
        "country" => { "enabled" => true, "required" => false },
        "postal_code" => { "enabled" => true, "required" => false },
        "date_of_birth" => { "enabled" => true, "required" => false },
        "gender" => { "enabled" => true, "required" => false },
        "phone_number" => { "enabled" => true, "required" => false, "pattern" => phone_number_pattern, "placeholder" => nil },
        "location" => { "enabled" => true, "required" => false },
        "underage" => { "enabled" => true, "required" => false, "limit" => 18 },
        "select_fields" => { "participant_type" => { "enabled" => true, "required" => false } },
        "boolean_fields" => { "ngo" => { "enabled" => true, "required" => false } },
        "text_fields" => { "motto" => { "enabled" => true, "required" => false } }
      }
    end
    let(:phone_number_pattern) { "^(\\+34)?[0-9 ]{9,12}$" }
    let(:user_password) { "decidim1234567890" }
    let(:old_password) { user_password }

    let(:name) { "Lord of the Foo" }
    let(:email) { "depths@ofthe.bar" }
    let(:nickname) { "foo_bar" }
    let(:password) { "Rf9kWTqQfyqkwseH" }
    let(:avatar) { upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")) }
    let(:remove_avatar) { false }
    let(:personal_url) { "http://example.org" }
    let(:about) { "This is a description about me" }
    let(:country) { "Argentina" }
    let(:date_of_birth) { "01/01/2000" }
    let(:gender) { "other" }
    let(:age_range) { "17_to_30" }
    let(:location) { "Paris" }
    let(:phone_number) { "0123456789" }
    let(:postal_code) { "75001" }
    let(:underage) { "0" }
    let(:select_fields) { { participant_type: "individual" } }
    let(:boolean_fields) { ["ngo"] }
    let(:text_fields) { { motto: false } }
    let(:statutory_representative_email) { nil }

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

    context "with invalid phone number format" do
      let(:phone_number) { "ABCDEFGHIJK" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "with non configured select fields" do
      let(:select_fields) { { participant_type: "individual", foo: "bar" } }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with incorrect select fields" do
      let(:select_fields) { { participant_type: "i_dont_exist" } }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "when a select field is required and blank" do
      let(:extra_user_fields) { { "enabled" => true, "country" => { "enabled" => true, "required" => false }, "select_fields" => { "participant_type" => { "enabled" => true, "required" => true } } } }
      let(:select_fields) { { participant_type: "" } }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:select_fields_participant_type]).to be_present
      end
    end

    context "when a text field is required and blank" do
      let(:extra_user_fields) { { "enabled" => true, "country" => { "enabled" => true, "required" => false }, "text_fields" => { "motto" => { "enabled" => true, "required" => true } } } }
      let(:text_fields) { { motto: "" } }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:text_fields_motto]).to be_present
      end
    end

    context "when a text field is optional and blank" do
      let(:extra_user_fields) { { "enabled" => true, "country" => { "enabled" => true, "required" => false }, "text_fields" => { "motto" => { "enabled" => true, "required" => false } } } }
      let(:text_fields) { { motto: "" } }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with non configured boolean fields" do
      let(:boolean_fields) { [:ngo, :foo] }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with non configured text fields" do
      let(:text_fields) { { motto: false, foo: true } }

      it "is valid" do
        expect(subject).to be_valid
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

      context "when it is already in use in the same organization" do
        context "and belongs to a user" do
          let!(:existing_user) { create(:user, email:, organization:) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end
      end

      context "when it is already in use in another organization" do
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

      context "when it is already in use in the same organization" do
        context "and belongs to a user" do
          let!(:existing_user) { create(:user, nickname:, organization:) }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end
      end

      context "when it is already in use in another organization" do
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

    describe "validate_old_password" do
      context "when email changed" do
        let(:password) { "" }
        let(:email) { "foo@example.org" }

        context "with correct old_password" do
          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "with incorrect old_password" do
          let(:old_password) { "foobar1234567890" }

          it { is_expected.not_to be_valid }
        end
      end

      context "when password present" do
        let(:email) { user.email }

        context "with correct old_password" do
          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "with incorrect old_password" do
          let(:old_password) { "foobar1234567890" }

          it { is_expected.not_to be_valid }
        end
      end
    end

    context "when country is required and blank" do
      let(:extra_user_fields) { { "enabled" => true, "country" => { "enabled" => true, "required" => true } } }
      let(:country) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:country]).to be_present
      end
    end

    context "when gender is required and blank" do
      let(:extra_user_fields) { { "enabled" => true, "gender" => { "enabled" => true, "required" => true } } }
      let(:gender) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:gender]).to be_present
      end
    end

    context "when extra user fields module is disabled" do
      let(:extra_user_fields) { { "enabled" => false, "country" => { "enabled" => true, "required" => true }, "gender" => { "enabled" => true, "required" => true } } }
      let(:country) { "" }
      let(:gender) { "" }

      it "bypasses extra field validations and is valid" do
        expect(subject).to be_valid
      end
    end

    describe "personal_url" do
      context "when it does not start with http" do
        let(:personal_url) { "example.org" }

        it "adds it" do
          expect(subject.personal_url).to eq("http://example.org")
        end
      end

      context "when it is not a valid URL" do
        let(:personal_url) { "foobar, aa" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
