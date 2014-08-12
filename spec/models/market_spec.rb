require 'spec_helper'

describe Market do
  describe 'validates' do
    let(:original_market) { create(:market) }

    describe "name" do
      it 'must be present' do
        market = build(:market)
        market.name = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end

      it 'is unique' do
        market = build(:market)
        market.name = original_market.name

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end

      it 'is less than 255 characters' do
        market = build(:market)
        market.name = "a" * 256

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end
    end

    describe "subdomain" do
      it 'must be present' do
        market = build(:market)
        market.subdomain = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end

      it 'is unique' do
        market = build(:market)
        market.subdomain = original_market.subdomain

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end

      it 'is less than 255 characters' do
        market = build(:market)
        market.subdomain = "a" * 256

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end

      it "cannot be a reserved name" do
        market = build(:market)
        market.subdomain = "app"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end
    end

    it 'tagline can be at most 255 characters' do
      market = build(:market)
      market.tagline = "a" * 256

      expect(market).to_not be_valid
      expect(market).to have(1).error_on(:tagline)
    end

    describe 'local_orbit_seller_fee' do
      it 'must be present' do
        market = build(:market)
        market.local_orbit_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end

      it 'must be positive' do
        market = build(:market)
        market.local_orbit_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end

      it 'must be less than 100' do
        market = build(:market)
        market.local_orbit_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end
    end

    describe 'local_orbit_market_fee' do
      it 'must be present' do
        market = build(:market)
        market.local_orbit_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end

      it 'must be positive' do
        market = build(:market)
        market.local_orbit_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end

      it 'must be less than 100' do
        market = build(:market)
        market.local_orbit_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end
    end

    describe 'market_seller_fee' do
      it 'must be present' do
        market = build(:market)
        market.market_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end

      it 'must be positive' do
        market = build(:market)
        market.market_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end

      it 'must be less than 100' do
        market = build(:market)
        market.market_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end
    end

    describe 'credit_card_seller_fee' do
      it 'must be present' do
        market = build(:market)
        market.credit_card_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end

      it 'must be positive' do
        market = build(:market)
        market.credit_card_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end

      it 'must be less than 100' do
        market = build(:market)
        market.credit_card_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end
    end

    describe 'credit_card_market_fee' do
      it 'must be present' do
        market = build(:market)
        market.credit_card_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end

      it 'must be positive' do
        market = build(:market)
        market.credit_card_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end

      it 'must be less than 100' do
        market = build(:market)
        market.credit_card_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end
    end

    describe 'ach_seller_fee' do
      it 'must be present' do
        market = build(:market)
        market.ach_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end

      it 'must be positive' do
        market = build(:market)
        market.ach_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end

      it 'must be less than 100' do
        market = build(:market)
        market.ach_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end
    end

    describe 'ach_market_fee' do
      it 'must be present' do
        market = build(:market)
        market.ach_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end

      it 'must be positive' do
        market = build(:market)
        market.ach_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end

      it 'must be less than 100' do
        market = build(:market)
        market.ach_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end
    end

    describe 'ach_fee_cap' do
      it 'must be present' do
        market = build(:market)
        market.ach_fee_cap = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_fee_cap)
      end

      it 'must be positive' do
        market = build(:market)
        market.ach_fee_cap = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_fee_cap)
      end

      it 'must be less than 10000' do
        market = build(:market)
        market.ach_fee_cap = "10000"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_fee_cap)
      end
    end

    context "po_payment_term" do
      it "can not be nil" do
        market = build(:market, po_payment_term: nil)

        expect(market).to have(2).error_on(:po_payment_term)
      end

      it "must be greater than 0" do
        market = build(:market, po_payment_term: 0)

        expect(market).to have(1).error_on(:po_payment_term)
      end

      it "must be less than a year" do
        market = build(:market, po_payment_term: 366)

        expect(market).to have(1).error_on(:po_payment_term)
      end
    end
  end

  describe '#fulfillment_locations' do
    let!(:market) { create(:market) }
    let!(:address1) { create(:market_address, market: market) }
    let!(:address2) { create(:market_address, market: market) }
    let(:default_name) { 'Direct to seller' }
    subject { market.fulfillment_locations(default_name) }

    it 'accepts a parameter as default option name' do
      expect(subject).to include([default_name, 0])
    end

    it 'has market address names' do
      expect(subject).to include([address1.name, address1.id])
      expect(subject).to include([address2.name, address2.id])
    end
  end

  describe "domain" do
    let(:market) { build(:market) }

    it "is is the subdomain with the canonical domain" do
      expect(market.domain).to eq("#{market.subdomain}.#{Figaro.env.domain!}")
    end
  end

  describe "#seller_net_percent" do
    let(:market) { build(:market, local_orbit_seller_fee: "1", local_orbit_market_fee: "2", market_seller_fee: "3", credit_card_seller_fee: "4", credit_card_market_fee: "5", ach_seller_fee: "6", ach_market_fee: "7") }

    it "includes appropriate seller fees" do
      expect(market.seller_net_percent).to eq(BigDecimal.new("0.90"))

      market.local_orbit_seller_fee = "3"
      expect(market.seller_net_percent).to eq(BigDecimal.new("0.88"))

      market.market_seller_fee = "6"
      expect(market.seller_net_percent).to eq(BigDecimal.new("0.85"))

      market.ach_seller_fee = "8"
      expect(market.seller_net_percent).to eq(BigDecimal.new("0.83"))
    end

    it "only includes the highest payment processing fee" do
      expect(market.seller_net_percent).to eq(BigDecimal.new("0.90"))

      market.ach_seller_fee = "1"
      expect(market.seller_net_percent).to eq(BigDecimal.new("0.92"))

      market.credit_card_seller_fee = "7"
      expect(market.seller_net_percent).to eq(BigDecimal.new("0.89"))

      market.ach_seller_fee = "8"
      expect(market.seller_net_percent).to eq(BigDecimal.new("0.88"))
    end
  end

  describe "next_delivery" do
    let!(:market) { create(:market) }
    let!(:delivery_schedule) { create(:delivery_schedule, market: market) }

    it 'builds and returns the next delivery' do
      delivery = market.next_delivery
      expect(delivery.delivery_schedule).to eq(delivery_schedule)
      expect(delivery.deliver_on).to be_future
      expect(delivery).to be_persisted
    end

    it 'returns nil if there are no valid delivery schedules' do
      delivery_schedule.soft_delete
      expect(market.next_delivery).to be_nil
    end
  end
end
