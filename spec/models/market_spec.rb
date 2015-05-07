require "spec_helper"

describe Market do

  subject{create(:market)}
  describe "validates" do
    let(:original_market) { create(:market) }

    describe "name" do
      it "must be present" do
        market = build(:market)
        market.name = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end

      it "is unique" do
        market = build(:market)
        market.name = original_market.name

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end

      it "is less than 255 characters" do
        market = build(:market)
        market.name = "a" * 256

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:name)
      end
    end

    describe "subdomain" do
      it "must be present" do
        market = build(:market)
        market.subdomain = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end

      it "is unique" do
        market = build(:market)
        market.subdomain = original_market.subdomain

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:subdomain)
      end

      it "is less than 255 characters" do
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

    it "tagline can be at most 255 characters" do
      market = build(:market)
      market.tagline = "a" * 256

      expect(market).to_not be_valid
      expect(market).to have(1).error_on(:tagline)
    end

    describe "local_orbit_seller_fee" do
      it "must be present" do
        market = build(:market)
        market.local_orbit_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.local_orbit_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.local_orbit_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_seller_fee)
      end
    end

    describe "local_orbit_market_fee" do
      it "must be present" do
        market = build(:market)
        market.local_orbit_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.local_orbit_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.local_orbit_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:local_orbit_market_fee)
      end
    end

    describe "market_seller_fee" do
      it "must be present" do
        market = build(:market)
        market.market_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.market_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.market_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:market_seller_fee)
      end
    end

    describe "credit_card_seller_fee" do
      it "must be present" do
        market = build(:market)
        market.credit_card_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.credit_card_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.credit_card_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_seller_fee)
      end
    end

    describe "credit_card_market_fee" do
      it "must be present" do
        market = build(:market)
        market.credit_card_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.credit_card_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.credit_card_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:credit_card_market_fee)
      end
    end

    describe "ach_seller_fee" do
      it "must be present" do
        market = build(:market)
        market.ach_seller_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.ach_seller_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.ach_seller_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_seller_fee)
      end
    end

    describe "ach_market_fee" do
      it "must be present" do
        market = build(:market)
        market.ach_market_fee = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end

      it "must be positive" do
        market = build(:market)
        market.ach_market_fee = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end

      it "must be less than 100" do
        market = build(:market)
        market.ach_market_fee = "100"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_market_fee)
      end
    end

    describe "ach_fee_cap" do
      it "must be present" do
        market = build(:market)
        market.ach_fee_cap = nil

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_fee_cap)
      end

      it "must be positive" do
        market = build(:market)
        market.ach_fee_cap = "-1"

        expect(market).to_not be_valid
        expect(market).to have(1).error_on(:ach_fee_cap)
      end

      it "must be less than 10000" do
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

      it "must be greater than or equal to 0" do
        market = build(:market, po_payment_term: -1)

        expect(market).to have(1).error_on(:po_payment_term)
      end

      it "must be less than a year" do
        market = build(:market, po_payment_term: 366)

        expect(market).to have(1).error_on(:po_payment_term)
      end
    end
  end

  describe "#store_closed_note" do
    it "stores text" do

      subject.store_closed_note = "We have closed this store."
      subject.save!
      subject.reload
      expect(subject.store_closed_note).to eq("We have closed this store.")
    end
  end


  describe "#fulfillment_locations" do
    let!(:market) { create(:market) }
    let!(:address1) { create(:market_address, market: market) }
    let!(:address2) { create(:market_address, market: market) }
    let(:default_name) { "Direct to seller" }
    subject { market.fulfillment_locations(default_name) }

    it "accepts a parameter as default option name" do
      expect(subject).to include([default_name, 0])
    end

    it "has market address names" do
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

    it "builds and returns the next delivery" do
      delivery = market.next_delivery
      expect(delivery.delivery_schedule).to eq(delivery_schedule)
      expect(delivery.deliver_on).to be_future
      expect(delivery).to be_persisted
    end

    it "returns nil if there are no valid delivery schedules" do
      delivery_schedule.soft_delete
      expect(market.next_delivery).to be_nil
    end
  end

  describe "#next_service_payment_at" do
    it "returns nil if plan_start_at or plan_interval are not set" do
      subject.plan_start_at = nil
      subject.plan_interval = nil

      expect(subject.next_service_payment_at).to be_nil

      subject.plan_start_at = 1.minute.from_now
      expect(subject.next_service_payment_at).to be_nil

      subject.plan_start_at = 1.minute.ago
      expect(subject.next_service_payment_at).to be_nil

      subject.plan_start_at = nil
      subject.plan_interval = 1
      expect(subject.next_service_payment_at).to be_nil

      subject.plan_start_at = nil
      subject.plan_interval = 12
      expect(subject.next_service_payment_at).to be_nil
    end

    context "monthly plan" do
      subject { create(:market, plan_interval: 1) }

      it "returns plan_start_at when plan starts in the future" do
        subject.plan_start_at = 1.day.from_now
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      it "returns plan_start_at when no payments have been made" do
        subject.plan_start_at = 1.minute.ago
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      it "returns plan_start_at when payments were made before the plan start" do
        create(:payment, :service, market: subject, payer: subject, created_at: 1.year.ago)
        subject.plan_start_at = Time.current
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      context "returns the next payment date based on the number of successful plan payments" do
        before do
          subject.plan_start_at = 58.days.ago
          create(:payment, :service, market: subject, payer: subject, created_at: 58.days.ago, status: "failed")
          create(:payment, :service, market: subject, payer: subject, created_at: 57.days.ago)
        end

        it "with 1 successful payment" do
          expect(subject.next_service_payment_at).to eq(1.month.from_now(subject.plan_start_at))
        end

        it "with 2 successful payments" do
          create(:payment, :service, market: subject, payer: subject, created_at: 28.days.ago)
          expect(subject.next_service_payment_at).to eq(2.months.from_now(subject.plan_start_at))
        end
      end
    end

    context "yearly plan" do
      subject { create(:market, plan_interval: 12) }

      it "returns plan_start_at when plan starts in the future" do
        subject.plan_start_at = 1.day.from_now
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      it "returns plan_start_at when no payments have been made" do
        subject.plan_start_at = 1.minute.ago
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      it "returns plan_start_at when payments were made before the plan start" do
        create(:payment, :service, market: subject, payer: subject, created_at: 1.week.ago)
        subject.plan_start_at = Time.current
        expect(subject.next_service_payment_at).to eq(subject.plan_start_at)
      end

      context "returns the next payment date based on the number of successful plan payments" do
        before do
          create(:payment, :service, market: subject, payer: subject, created_at: 375.days.ago, status: "failed")
          create(:payment, :service, market: subject, payer: subject, created_at: 374.days.ago)
          subject.plan_start_at = 375.days.ago
        end

        it "with 1 successful payment" do
          expect(subject.next_service_payment_at).to eq(1.year.from_now(subject.plan_start_at))
        end

        it "with 2 successful payments" do
          create(:payment, :service, market: subject, payer: subject, created_at: 11.days.ago)
          expect(subject.next_service_payment_at).to eq(2.years.from_now(subject.plan_start_at))
        end
      end
    end
  end

  describe "changing plan" do
    context "disables cross-selling" do
      let!(:old_plan) { create(:plan, cross_selling: true) }
      let!(:new_plan) { create(:plan, cross_selling: false) }

      let!(:market1)  { create(:market, plan: old_plan, allow_cross_sell: true) }
      let!(:org1)     { create(:organization, :seller, markets: [market1]) }
      let!(:market2)  { create(:market) }
      let!(:org2)     { create(:organization, :seller, markets: [market2]) }

      before do
        # Member organization cross-selling on another market
        MarketOrganization.create(market_id: market2.id, organization_id: org1.id, cross_sell_origin_market_id: market1.id)

        # Non-member organization cross-selling on this market
        MarketOrganization.create(market_id: market1.id, organization_id: org2.id, cross_sell_origin_market_id: market2.id)

        market1.update(plan: new_plan)
      end

      it "disables other markets from seeing it as a cross selling market" do
        expect(market1.reload.allow_cross_sell).to eql(false)
      end

      it "removes any member organization from cross selling on other markets" do
        expect(MarketOrganization.where(cross_sell_origin_market_id: market1.id, deleted_at: nil).count).to eql(0)
      end

      it "removes any non-member organizations from cross selling on the market" do
        expect(MarketOrganization.where.not(cross_sell_origin_market_id: nil).where(market_id: market1.id, deleted_at: nil).count).to eql(0)
      end
    end

    context "updates the markets products" do
      let!(:old_plan) { create(:plan, advanced_inventory: true) }
      let!(:new_plan) { create(:plan, advanced_inventory: false) }

      let!(:market1)  { create(:market, plan: old_plan, allow_cross_sell: true) }
      let!(:org1)     { create(:organization, :seller, markets: [market1]) }
      let!(:product1) { create(:product, organization: org1, use_simple_inventory: false) }
      let!(:lot1)     { create(:lot, product: product1, quantity: 25) }
      let!(:lot2)     { create(:lot, product: product1, quantity: 35) }

      it "updates product inventory for a market downgrading service plan" do
        expect(product1.reload.lots.count).to eql(2)

        market1.update(plan: new_plan)

        expect(product1.reload.lots.count).to eql(1)
      end
    end
  end

  describe "#local_orbit_seller_and_market_fee_fraction" do
    let(:market) { create(:market, local_orbit_seller_fee: "1.0".to_d, local_orbit_market_fee: "2.0".to_d) }
    it "returns a combination of seller and market fees due LO divided by 100" do
      expect(market.local_orbit_seller_and_market_fee_fraction).to eq "0.03".to_d
    end
  end

  describe "#credit_card_payment_fee_payer" do
    let(:market) { create(:market) }
    [
      [{ credit_card_seller_fee: 0, credit_card_market_fee: 0 }, 'market' ],
      [{ credit_card_seller_fee: 0, credit_card_market_fee: 1 }, 'market' ],
      [{ credit_card_seller_fee: 1, credit_card_market_fee: 0 }, 'seller' ],
      [{ credit_card_seller_fee: 1, credit_card_market_fee: 1 }, 'seller' ],
    ].each do |(input, output)|
      it "returns #{output.inspect} when #{input.inspect}" do
        market.update(input)
        expect(market.credit_card_payment_fee_payer).to eq output
      end
    end
  end
end
