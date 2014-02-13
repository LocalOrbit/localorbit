require 'spec_helper'

describe Admin::OrganizationsController do
  describe "/show" do
    let(:org) { create(:organization) }

    describe "a normal user" do
      let(:user) { create(:user, role: 'user') }

      before do
        sign_in user
      end

      it "cannot access an organization they don't belong to" do
        get :show, {id: org.id}
        expect(response).to be_not_found
      end

      it "can edit their organization" do
        user.organizations << org
        get :show, {id: org.id}
        expect(response).to be_success
      end
    end
  end

  describe "/new" do
    describe "a normal user" do
      let(:user) { create(:user, role: 'user') }

      before do
        sign_in user
      end

      it "cannot create a new organization" do
        get :new
        expect(response).to be_not_found
      end
    end
  end

  describe "/edit" do
    let(:org) { create(:organization) }

    describe "a normal user" do
      let(:user) { create(:user, role: 'user') }

      before do
        sign_in user
      end

      it "cannot access an organization they don't belong to" do
        get :edit, {id: org.id}
        expect(response).to be_not_found
      end

      it "can edit their organization" do
        user.organizations << org
        get :edit, {id: org.id}
        expect(response).to be_success
      end
    end
  end
end
