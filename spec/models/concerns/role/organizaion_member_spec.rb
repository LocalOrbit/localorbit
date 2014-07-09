require "spec_helper"

describe Role::MarketManager do
  let!(:user) { create(:user) }
  let!(:market) { create(:market) }
  let!(:organization) { create(:organization, :buyer, users: [user]) }

  subject{ user.set_role_context }

  before do
    user.extend Role::OrganizationMember
  end

  it { is_expected.to be_admin }
end
