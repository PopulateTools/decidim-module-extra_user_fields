# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ApplicationController do
    controller do
      def index
        render plain: "OK"
      end
    end

    let(:organization) { create(:organization, extra_user_fields:) }
    let(:user) { create(:user, :confirmed, organization:, extended_data:) }
    let(:extended_data) { {} }
    let(:extra_user_fields) { { "enabled" => true, "country" => { "enabled" => true, "required" => true } } }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user, scope: :user
    end

    context "when user has incomplete extra fields" do
      it "redirects to account path" do
        get :index

        expect(response).to redirect_to("/account")
      end

      it "sets a warning flash message" do
        get :index

        expect(flash[:warning]).to include("complete your profile")
      end
    end

    context "when user has completed extra fields" do
      let(:extended_data) { { "country" => "ES" } }

      it "does not redirect" do
        get :index

        expect(response).to have_http_status(:ok)
      end
    end

    context "when no fields are required (all optional)" do
      let(:extra_user_fields) { { "enabled" => true, "country" => { "enabled" => true, "required" => false } } }

      it "does not redirect" do
        get :index

        expect(response).to have_http_status(:ok)
      end
    end

    context "when request format is JSON" do
      it "does not redirect" do
        get :index, format: :json

        expect(response).to have_http_status(:ok)
      end
    end

    context "when user has not accepted ToS" do
      let(:user) { create(:user, :confirmed, :tos_not_accepted, organization:, extended_data:) }

      it "does not trigger extra fields redirect" do
        get :index

        expect(response).not_to redirect_to("/account")
      end
    end
  end
end
