require 'spec_helper'

describe RemoveOrganizationFromMarkets do
  let(:market) { create(:market) }

  context "organization has no cross-sells configured" do
    let(:market2) { create(:market) }

    it "removes an organization from a market" do
      organization = create(:organization, markets: [market, market2])
      expect(MarketOrganization.count).to eq(2)

      remove_organization_from_market = RemoveOrganizationFromMarkets.perform(
        market_ids: [market.id], organization: organization
      )

      organization.reload
      expect(organization.markets).to eq([market2])
      expect(MarketOrganization.count).to eq(2) # Ensure soft deletion
    end
  end

  context "organization has cross-sells" do
    it "removes the cross sells that originate from the market that's being removed" do
      cross_sell_to = create(:market)

      organization = create(:organization, markets: [market])
      organization.update_cross_sells!(from_market: market, to_ids: [cross_sell_to.id])
      expect(MarketOrganization.count).to eq(2)

      remove_organization_from_market = RemoveOrganizationFromMarkets.perform(
        market_ids: [market.id], organization: organization
      )

      organization.reload
      expect(organization.markets).to eq([])
      expect(organization.cross_sells).to eq([])
      expect(MarketOrganization.count).to eq(2) # Ensure soft deletion
    end

    it "does not remove cross sells that originate from other markets, even if cross sell to the market being removed" do
      cross_sell_from = create(:market)

      organization = create(:organization, markets: [market, cross_sell_from])
      organization.update_cross_sells!(from_market: cross_sell_from, to_ids: [market.id])

      remove_organization_from_market = RemoveOrganizationFromMarkets.perform(
        market_ids: [market.id], organization: organization
      )

      organization.reload
      expect(organization.markets).to eq([cross_sell_from])
      expect(organization.cross_sells).to eq([market])
    end
  end

  it "returns a helpful message when passing no parameters" do
    cross_sell_from = create(:market)

    organization = create(:organization, markets: [market, cross_sell_from])
    organization.update_cross_sells!(from_market: cross_sell_from, to_ids: [market.id])

    expect(organization.markets).to contain_exactly(market, cross_sell_from)
    expect(organization.cross_sells).to eq([market])

    remove_organization_from_market = RemoveOrganizationFromMarkets.perform(
      market_ids: [], organization: organization
    )

    expect(remove_organization_from_market).to be_failure
    expect(remove_organization_from_market.error).to eq("Please choose at least one market to remove #{organization.name} from.")

    organization.reload
    expect(organization.markets).to contain_exactly(market, cross_sell_from)
    expect(organization.cross_sells).to eq([market])
  end
end