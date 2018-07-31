require "spec_helper"

describe MarketMailer do
  describe "fresh_sheet" do
    let!(:fulton_farms) { create(:organization, :seller, name: "Fulton St. Farms") }
    let!(:ada_farms)    { create(:organization, :seller, name: "Ada Farms") }

    let!(:market_in)  { create(:market, organizations: [fulton_farms], contact_phone: "616-123-4567") }
    let!(:market_out) { create(:market, organizations: [ada_farms]) }

    let!(:delivery_schedule1) { create(:delivery_schedule, market: market_in, day: 5, order_cutoff: 24, buyer_pickup_start: "12:00 PM", buyer_pickup_end: "2:00 PM") }
    let!(:delivery_schedule2) { create(:delivery_schedule, market: market_out, day: 5, order_cutoff: 24, buyer_pickup_start: "12:00 PM", buyer_pickup_end: "2:00 PM") }

    let!(:product_in)  { create(:product, :sellable, delivery_schedules: [delivery_schedule1], organization: fulton_farms) }
    let!(:product_out) { create(:product, :sellable, delivery_schedules: [delivery_schedule2], organization: ada_farms) }

    include_context "fresh sheet and newsletter subscription types"

    let!(:token) {"xyz--unsubscribe-me-987"}

    it "only shows products for the given market" do
      user = create(:user)
      fresh_sheet = MarketMailer.fresh_sheet(market: market_in, to: user.pretty_email, unsubscribe_token: token)
      expect(fresh_sheet.body).to include(product_in.name)
      expect(fresh_sheet.body).to include(product_in.organization.name)

      expect(fresh_sheet.body).not_to include(product_out.name)
      expect(fresh_sheet.body).not_to include(product_out.organization.name)

      expect(fresh_sheet.body).to include("For customer service please reply to this email")
      expect(fresh_sheet.body).to include("616-123-4567")
      expect(fresh_sheet.body).to include("Click here to")
      expect(fresh_sheet.body).to include(%|href="#{unsubscribe_subscriptions_url(host:market_in.domain, token:token)}"|)
    end

    it "displays the fresh sheet note if present" do
      fresh_sheet = MarketMailer.fresh_sheet(market: market_in, note: "Rockin")

      expect(fresh_sheet.body).to include("Rockin")
      expect(fresh_sheet.body).not_to include("Click here to")
      expect(fresh_sheet.body).not_to include(%|href="#{unsubscribe_subscriptions_url(token:token)}"|)
    end
  end

  describe 'registration' do
    let(:market)   { create(:market, organizations: [organization]) }
    let!(:manager) { create(:user, :market_manager, managed_markets: [market]) }
    let(:mailer)   { MarketMailer.registration(market, organization) }

    context 'new supplier mail' do
      let(:organization) { create(:organization, :seller, :single_location, active: false) }
      let!(:user)        { create(:user, :supplier, organizations: [organization]) }

      it 'is sent to market manager' do
        expect(mailer).to deliver_to([manager.email])
      end

      it 'has correct role in subject' do
        expect(mailer.subject).to eq('New supplier registration')
      end

      it 'includes company name' do
        expect(mailer.body).to have_content("Company: #{organization.name}")
      end

      it 'does not include buyer type' do
        expect(mailer.body).to_not have_content('Buyer Type:')
      end

      it 'includes user name' do
        expect(mailer.body).to have_content("Name: #{user.name}")
      end

      it 'includes user email' do
        expect(mailer.body).to have_content("Email: #{user.email}")
      end

      it 'includes organization phone' do
        expect(mailer.body).to have_content("Phone: #{organization.locations.first.phone}")
      end

      it 'includes organization address' do
        l = organization.locations.first
        expect(mailer.body).to have_content("Address: #{l.name} #{l.address} #{l.city}, #{l.state} #{l.zip}")
      end

      it 'includes Edit Organization button' do
        expect(mailer.body).to have_link('Edit Organization', href: admin_organization_url(organization, host: market.domain))
      end
    end

    context 'new buyer mail' do
      let(:organization) { create(:organization, :buyer, :single_location, active: false) }
      let!(:user)        { create(:user, :buyer, organizations: [organization]) }

      it 'has correct role in subject' do
        expect(mailer.subject).to eq('New buyer registration')
      end

      it 'includes buyer type' do
        expect(mailer.body).to have_content("Buyer Type: #{organization.buyer_org_type}")
      end
    end
  end
end
