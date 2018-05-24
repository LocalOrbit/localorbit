require "spec_helper"

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
      UpdateCrossSellingMarketOrganizations.perform(
        organization: organization,
        source_market_id: market.id,
        destination_market_ids: [cross_sell_to.id])
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
      UpdateCrossSellingMarketOrganizations.perform(
        organization: organization,
        source_market_id: cross_sell_from.id,
        destination_market_ids: [market.id])
      remove_organization_from_market = RemoveOrganizationFromMarkets.perform(
        market_ids: [market.id], organization: organization
      )

      organization.reload
      expect(organization.markets).to eq([cross_sell_from])
      expect(organization.cross_sells).to eq([market])
    end
  end

  context "organization has promotional items" do
    it "removes the promotions for the organization" do
      organization = create(:organization, markets: [market])
      product = create(:product, :sellable, organization: organization)
      promotion = create(:promotion, market: market, product: product)

      expect(Promotion.count).to eql(1)

      remove_organization_from_market = RemoveOrganizationFromMarkets.perform(
        market_ids: [market.id], organization: organization
      )

      expect(Promotion.count).to eql(0)
    end

    it "does not remove promitional items for other organizations" do
      organization = create(:organization, markets: [market])
      other_organization = create(:organization, markets: [market])
      product = create(:product, :sellable, organization: other_organization)
      promotion = create(:promotion, market: market, product: product)

      expect(Promotion.count).to eql(1)

      remove_organization_from_market = RemoveOrganizationFromMarkets.perform(
        market_ids: [market.id], organization: organization
      )

      expect(Promotion.count).to eql(1)
    end
  end

  it "returns a helpful message when passing no parameters" do
    cross_sell_from = create(:market)

    organization = create(:organization, markets: [market, cross_sell_from])
    UpdateCrossSellingMarketOrganizations.perform(
      organization: organization,
      source_market_id: cross_sell_from.id,
      destination_market_ids: [market.id])

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
