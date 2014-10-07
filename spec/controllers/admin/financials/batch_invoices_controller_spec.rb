require "spec_helper"

describe Admin::Financials::BatchInvoicesController do

  let(:market)                    { create(:market) }
  let(:organization)              { create(:organization, markets: [market]) }
  let(:admin)                     { create(:user, :admin) }
  let(:market_manager_member)     { create(:user, managed_markets: [market]) }
  let(:market_manager_non_member) { create(:user, :market_manager) }
  let(:member)                    { create(:user, organizations: [organization]) }
  let(:user)                      { create(:user, organizations: [organization]) }
  let(:non_member)                { create(:user) }

  let(:batch_invoice) { create(:batch_invoice, user: user) }

  let(:action) do  
    -> { get :show, id: batch_invoice.id }
  end

  before do
    switch_to_subdomain market.subdomain
  end

  it "grants access to owner of the BatchInvoice" do
    sign_in user
    instance_exec(&action)
    expect(response).to be_a_success
  end

  it "grants access to admins" do
    sign_in admin
    instance_exec(&action)
    expect(response).to be_a_success
  end

  it "prevents access when not signed in" do
    instance_exec(&action)
    expect(response).to redirect_to(new_user_session_path)
  end

  it "prevents access when not a member of the organization" do
    sign_in non_member
    instance_exec(&action)
    expect(response).to be_not_found
  end

  it "prevents access to market managers of another organization" do
    sign_in market_manager_non_member
    instance_exec(&action)
    expect(response).to be_not_found
  end

  it "prevents access to organization members" do
    sign_in member
    instance_exec(&action)
    expect(response).to be_not_found
  end

end
