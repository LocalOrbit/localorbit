require 'spec_helper'

describe Newsletter do
  describe "#recipients" do
    let!(:market_manager) { create :user, :market_manager, send_newsletter: true }
    let!(:market) { market_manager.managed_markets.first }
    let!(:newsletter) { create(:newsletter, market: market) }
    let!(:buyer_org) { create(:organization, :buyer, markets: [newsletter.market]) }
    let!(:seller_org) { create(:organization, :seller, markets: [newsletter.market]) }
    let!(:buyer) { create(:user, send_newsletter: true, organizations: [buyer_org]) }
    let!(:seller) { create(:user, send_newsletter: true, organizations: [seller_org]) }

    it "can include buyers" do
      newsletter.buyers = true
      emails = newsletter.recipients.map{|name, email| email }
      expect(emails).to include(buyer.email)
      expect(emails).not_to include(seller.email)
      expect(emails).not_to include(market_manager.email)
    end

    it "can include sellers" do
      newsletter.sellers = true
      emails = newsletter.recipients.map{|name, email| email }
      expect(emails).to include(seller.email)
      expect(emails).not_to include(buyer.email)
      expect(emails).not_to include(market_manager.email)
    end

    it "can include market managers" do
      newsletter.market_managers = true
      emails = newsletter.recipients.map{|name, email| email }
      expect(emails).to include(market_manager.email)
      expect(emails).not_to include(buyer.email)
      expect(emails).not_to include(seller.email)
    end

    it "can include all groups" do
      newsletter.buyers = true
      newsletter.sellers = true
      newsletter.market_managers = true
      emails = newsletter.recipients.map{|name, email| email }
      expect(emails).to include(market_manager.email)
      expect(emails).to include(buyer.email)
      expect(emails).to include(seller.email)
    end
  end
end
