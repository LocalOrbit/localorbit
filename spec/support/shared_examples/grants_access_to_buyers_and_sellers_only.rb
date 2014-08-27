shared_examples "an action that grants access to buyers and sellers only" do |action|
  let(:market)                    { create(:market) }
  let(:organization)              { create(:organization, :buyer, markets: [market]) }
  let(:seller_organization)       { create(:organization, :seller, markets: [market]) }
  let(:admin)                     { create(:user, :admin) }
  let(:market_manager)            { create(:user, managed_markets: [market]) }
  let(:buyer_only)                { create(:user, organizations: [organization]) }
  let(:seller)                    { create(:user, organizations: [seller_organization]) }
  let!(:order)                    { create(:order, organization: seller_organization) }

  def meet_expected_expectation
    %w(show).include?(controller.action_name) ? be_a_success : be_a_redirect
  end

  it "redirects to login given no user" do
    instance_exec(&action)

    expect(response).to redirect_to(new_user_session_path)
  end

  it "prevents access to market managers" do
    sign_in market_manager

    instance_exec(&action)

    expect(response).to be_not_found
  end

  it "grants access to sellers" do
    sign_in seller

    instance_exec(&action)

    expect(response).to meet_expected_expectation
  end

  it "grants access to buyer only" do
    sign_in buyer_only

    instance_exec(&action)

    expect(response).to meet_expected_expectation
  end

  it "prevents access to admins" do
    sign_in admin

    instance_exec(&action)

    expect(response).to be_not_found
  end
end
