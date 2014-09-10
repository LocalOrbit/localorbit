require "spec_helper"

describe Product do
  describe "validations" do
    describe "organization" do
      let(:buyer) { build(:organization, :buyer) }
      let(:seller) { build(:organization, :seller) }

      it "is valid if the organization is a seller" do
        subject.organization = seller
        subject.valid?
        expect(subject.errors[:organization]).to be_empty
      end

      it "is invalid if the organization is not a seller" do
        subject.organization = buyer
        subject.valid?

        expect(subject.errors[:organization]).to include("must be able to sell products")
      end
    end

    it "category is required" do
      expect(subject).to have(1).error_on(:category_id)
    end

    it "name is required" do
      expect(subject).to have(1).error_on(:name)
    end

    it "requires a unit type" do
      expect(subject).to have(1).error_on(:unit)
    end
  end

  describe "default values" do
    describe "#top_level_category_id" do
      let(:org) { create(:organization) }
      let(:unit) { create(:unit) }
      let(:top_level) { create(:category, parent: Category.root) }
      let!(:category) { create(:category, parent: top_level) }
      subject { Product.create!(short_description: "desc", name: "New Product", organization: org, category: category, unit: unit) }

      it "assigns the top level based on category" do
        expect(subject.top_level_category).to eql(top_level)
      end
    end
  end

  describe ".available_for_sale" do
    let(:market)      { create(:market) }
    let(:market2)     { create(:market) }
    let(:org_in)      { create(:organization, markets: [market]) }
    let(:buyer)       { create(:organization, markets: [market]) }
    let(:other_buyer) { create(:organization, markets: [market]) }

    let(:product_in)                    { create(:product, organization: org_in) }
    let(:product_in_no_price)           { create(:product, organization: org_in) }
    let(:product_in_no_lot)             { create(:product, organization: org_in) }
    let(:product_in_other_buyer_price)  { create(:product, organization: org_in) }
    let(:product_in_other_market_price) { create(:product, organization: org_in) }
    let(:product_in_for_buyer)          { create(:product, organization: org_in) }
    let(:product_in_expiring_lot)        { create(:product, organization: org_in) }

    before do
      create(:price, product: product_in)
      create(:price, product: product_in_no_lot)
      create(:price, product: product_in_other_buyer_price, organization: other_buyer)
      create(:price, product: product_in_other_market_price, market: market2)
      create(:price, product: product_in_for_buyer, organization: buyer)
      create(:price, product: product_in_expiring_lot)

      create(:lot, product: product_in)
      create(:lot, product: product_in_no_price)
      create(:lot, product: product_in_other_buyer_price)
      create(:lot, product: product_in_other_market_price)
      create(:lot, product: product_in_for_buyer)
      create(:lot, product: product_in_expiring_lot, number: "1", expires_at: 3.days.from_now)
    end

    context "with an organization" do
      it "contains the correct products" do
        products = Product.available_for_sale(market, buyer, 2.days.from_now)
        expect(products.to_a.size).to eq(3)
        expect(products).to include(product_in, product_in_for_buyer, product_in_expiring_lot)
      end

      it "excludes products that do not have unexpired inventory" do
        products = Product.available_for_sale(market, buyer, 6.days.from_now)
        expect(products.to_a.count).to eq(2)
      end

      it "excludes products from organizations who cannot sell" do
        org_in.update!(can_sell: false)
        products = Product.available_for_sale(market, buyer, 2.days.from_now)
        expect(products.to_a.count).to eq(0)
      end
    end

    context "without an organization" do
      it "contains the correct products" do
        expect(Product.available_for_sale(market)).to include(product_in, product_in_expiring_lot)
      end
    end
  end

  describe ".for_organization_id" do
    let(:product1) { create(:product) }
    let(:product2) { create(:product) }

    it "returns products sold by organization" do
      expect(Product.for_organization_id(product1.organization_id)).to match_array([product1])
    end
  end

  describe "#can_use_simple_inventory?" do
    let!(:market) { create(:market) }
    let!(:seller) { create(:organization, :seller, markets: [market]) }
    let(:product) { create(:product, organization: seller, use_simple_inventory: false) }

    it "is true if they are using simple inventory" do
      product.use_simple_inventory = true
      product.lots.create!(quantity: 10)

      expect(product.can_use_simple_inventory?).to be true
    end

    it "is true if all lots have expired" do
      lot = product.lots.create!(quantity: 2, number: "1")
      lot.update_attribute(:expires_at, 1.day.ago)

      expect(product.can_use_simple_inventory?).to be true
    end

    it "is true if all non-expired lots have no quantity" do
      product.lots.create!(quantity: 0, number: "1")
      product.lots.create!(quantity: 0, number: "2", expires_at: 2.days.from_now)
      product.lots.create!(quantity: 0, number: "3", good_from: 1.day.from_now, expires_at: 2.days.from_now)

      expect(product.can_use_simple_inventory?).to be true
    end

    it "is false if any lots with quantity have not expired" do
      product.lots.create!(quantity: 10, number: "1", expires_at: 2.days.from_now)

      expect(product.can_use_simple_inventory?).to be false
    end

    it "is false if any lots have a quantity" do
      product.lots.create!(quantity: 10, number: "1")

      expect(product.can_use_simple_inventory?).to be false
    end

    it "is false if any future lots have a quantity" do
      product.lots.create!(quantity: 10, number: "1", good_from: 1.day.from_now)

      expect(product.can_use_simple_inventory?).to be false
    end
  end

  describe "#simple_inventory" do
    let!(:market) { create(:market) }
    let!(:seller) { create(:organization, :seller, markets: [market]) }

    subject { create(:product, organization: seller) }

    before do
      subject.use_simple_inventory = true
    end

    it "returns 0 for a new product" do
      expect(subject.simple_inventory).to eq(0)
    end

    it "does not return the quantity of an expired lot" do
      subject.lots.build(number: "1", expires_at: 2.days.ago, quantity: 42)
      expect(subject.simple_inventory).to eq(0)
    end

    it "returns the available inventory for the product" do
      subject.lots.build(quantity: 42)
      expect(subject.simple_inventory).to eq(42)
    end
  end

  describe "#simple_inventory=" do
    let!(:market) { create(:market) }
    let!(:seller) { create(:organization, :seller, markets: [market]) }

    it "sets errors for negative numbers" do
      subject.simple_inventory = -10
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to include("Simple inventory quantity must be greater than or equal to 0")
    end

    context "use_simple_inventory is set" do
      describe "on create" do
        subject { build(:product, organization: seller, use_simple_inventory: true) }

        before do
          subject.simple_inventory = "42"
        end

        it "creates a new lot with the assigned quantity" do
          expect {
            subject.save!
          }.to change {
            Lot.where(product_id: subject.id).count
          }.from(0).to(1)
        end

        it "new lot has assigned quantity" do
          expect(subject.lots.last.quantity).to eq(42)
        end
      end

      describe "on update" do
        subject { create(:product, organization: seller, use_simple_inventory: true) }

        it "updates the newest lot with the assigned quantity" do
          subject.lots.create!(number: "1", expires_at: 1.day.from_now, quantity: 0, created_at: 3.days.ago)
          simple_lot = subject.lots.create!(quantity: 12)
          subject.simple_inventory = 42

          expect {
            subject.save!
          }.to change {
            Lot.find(simple_lot.id).quantity
          }.from(12).to(42)
        end

        it "create a new lot if one doesn't exist" do
          subject.simple_inventory = 42
          expect {
            subject.save!
          }.to change {
            Lot.where(product_id: subject.id).count
          }.from(0).to(1)
        end

        it "sets the quantity on the new lot to the assigned quantity" do
          subject.simple_inventory = 42
          subject.save!
          expect(subject.lots(true).last.quantity).to eq(42)
        end

        it "does not use a lot with a future good from date" do
          subject.lots.create!(number: "1", created_at: 1.minute.ago, good_from: 1.day.from_now, expires_at: 2.days.from_now, quantity: 0)

          expect {
            subject.simple_inventory = 42
            subject.save!
          }.to change {
            Lot.where(product_id: subject.id).count
          }.by(1)

          lot = subject.lots(true).last
          expect(lot.quantity).to eq(42)
          expect(lot.number).to be_nil
        end
      end
    end

    context "use_simple_inventory is not set" do
      before do
        subject.use_simple_inventory = false
      end

      context "new record" do
        subject { build(:product, use_simple_inventory: false) }

        it "does not create a new lot" do
          subject.simple_inventory = '6'
          expect {
            subject.save!
          }.to_not change{
            Lot.count
          }
        end
      end

      context "existing record" do
        subject{ create(:product, organization: seller, use_simple_inventory: false) }

        context "with no lots" do
          it "does not create a new lot" do
            subject.simple_inventory = '6'
            expect {
              subject.save!
            }.to_not change{
              Lot.count
            }
          end
        end

        context "with existing lots" do
          before do
            subject.lots.create!(quantity: 12)
            subject.simple_inventory = "6"
            subject.save!
          end

          it "does not create any lots" do
            expect(Lot.count).to eq(1)
          end

          it "does not update any lots" do
            expect(Lot.first.quantity).to eq(12)
          end
        end
      end
    end
  end

  describe "#available_inventory" do
    context "using simple inventory" do
      context "with no inventory set" do
        subject { create(:product, use_simple_inventory: true) }

        it "returns 0" do
          expect(subject.available_inventory).to eq(0)
        end
      end

      context "with inventory set" do
        subject { create(:product, use_simple_inventory: true, simple_inventory: 42) }

        it "returns simple inventory quantity" do
          expect(subject.available_inventory).to eq(42)
        end
      end
    end

    context "using advanced inventory" do
      let!(:product) { create(:product, use_simple_inventory: false) }

      subject { product }

      context "with no inventory set" do
        it "returns 0" do
          expect(subject.available_inventory).to eq(0)
        end
      end

      context "with available inventory lots" do
        let!(:lot1) { create(:lot, product: product, quantity: 42) }
        let!(:lot2) { create(:lot, product: product, quantity: 24) }

        it "returns the sum of the available lot inventory" do
          expect(subject.available_inventory).to eq(66)
        end

        context "that are expired" do
          let!(:expired_lot) { create(:lot, created_at: 2.days.ago, number: "1", expires_at: 1.minute.from_now, quantity: 50) }

          it "returns the sum of the available lot inventory" do
            expired_lot.update_attribute(:expires_at, 1.day.ago)

            expect(subject.available_inventory).to eq(66)
          end
        end

        context "that have not reached their good_from date" do
          let!(:not_good_yet) { create(:lot, created_at: 2.days.ago, number: "1", good_from: 2.days.from_now, expires_at: 1.week.from_now, quantity: 50) }

          it "returns the sum of the available lot inventory" do
            expect(subject.available_inventory).to eq(66)
          end
        end
      end
    end
  end

  describe "#minimum_quantity_for_purchase" do
    let(:product) { create(:product) }
    let(:market) { create(:market) }
    let(:buyer) { create(:organization, :buyer, markets: [market]) }
    let(:minimum) do
      product.minimum_quantity_for_purchase(organization: buyer, market: market)
    end

    context "general pricing" do
      before do
        product.prices << create(:price, min_quantity: 1)
        product.prices << create(:price, min_quantity: 3)
        product.save!
      end

      it "finds the minimum quantity required to purchase" do
        expect(minimum).to eql(1)
      end
    end

    context "organization specific pricing" do
      let(:special_buyer) { create(:organization, markets: [market]) }
      let(:special_minimum) do
        product.minimum_quantity_for_purchase(organization: special_buyer, market: market)
      end

      before do
        product.prices << create(:price, min_quantity: 50, organization: special_buyer)
        product.prices << create(:price, min_quantity: 87)
        product.prices << create(:price, min_quantity: 100)
        product.save!
      end

      it "finds the minimum quantity require to purchase" do
        expect(minimum).to eql(87)
        expect(special_minimum).to eql(50)
      end
    end

    context "product has no prices" do

      it "is nil" do
        quantity = product.minimum_quantity_for_purchase(market: market, organization: buyer)
        expect(quantity).to be_nil
      end
    end
  end

  describe "#prices_for_organization" do
    let(:market)             { create(:market) }
    let(:other_market)       { create(:market) }
    let(:org)                { create(:organization) }
    let(:everyone_price)     { create(:price, sale_price: 10.00) }
    let(:overridden_price)   { create(:price, min_quantity: 5, sale_price: 9.00) }
    let(:org_price)          { create(:price, min_quantity: 5, sale_price: 8.00, market: market, organization: org) }
    let(:other_market_price) { create(:price, min_quantity: 2, sale_price: 5.00, market: other_market) }
    let(:product)            { create(:product, prices: [everyone_price, overridden_price, org_price, other_market_price]) }

    it "returns the correct prices" do
      expect(product.prices_for_market_and_organization(market, org)).to eql([everyone_price, org_price])
    end
  end

  describe "#update_delivery_schedules" do
    let!(:market)             { create(:market) }
    let!(:monday_delivery)    { create(:delivery_schedule, market: market, day: 1) }

    let!(:market2)            { create(:market) }
    let!(:wednesday_delivery) { create(:delivery_schedule, market: market2, day: 3) }

    context "using all deliveries" do
      context "single market membership" do
        let!(:organization) { create(:organization, :seller, markets: [market]) }
        let!(:product) { create(:product, organization: organization) }

        it "adds all deliveries" do
          expect(product.delivery_schedules.count).to eql(1)
          expect(product.delivery_schedules).to include(monday_delivery)
        end
      end

      context "multi-market membership" do
        let!(:organization) { create(:organization, :seller, markets: [market, market2]) }
        let!(:product) { create(:product, organization: organization) }

        it "adds all deliveries" do
          expect(product.delivery_schedules.count).to eql(2)
          expect(product.delivery_schedules).to include(monday_delivery, wednesday_delivery)
        end
      end
    end

    context "manually managing deliveries" do
      context "single market membership" do
        let!(:organization) { create(:organization, :seller, markets: [market]) }
        let!(:product) { create(:product, use_all_deliveries: false, organization: organization) }

        it "does not automatically add delivery schedules" do
          expect(product.delivery_schedules.count).to eql(0)
        end

        it "allows unselecting all delivery schedules" do
          product.delivery_schedules = [monday_delivery]
          expect(product.delivery_schedules.count).to eql(1)

          product.delivery_schedule_ids = []
          product.save

          expect(product.reload.delivery_schedules.count).to eql(0)
        end
      end

      context "multi-market membership" do
        let!(:organization) { create(:organization, :seller, markets: [market, market2]) }
        let!(:product) { create(:product, use_all_deliveries: false, organization: organization) }

        it "does not automatically add delivery schedules" do
          expect(product.delivery_schedules.count).to eql(0)
        end

        it "removes delivery schedules from markets that are not part of the organization" do
          product.delivery_schedules = [monday_delivery, wednesday_delivery]
          expect(product.delivery_schedules.count).to eql(2)

          organization.markets = [market]
          product.save

          expect(product.delivery_schedules.count).to eql(1)
          expect(product.delivery_schedules).to include(monday_delivery)
          expect(product.delivery_schedules).to_not include(wednesday_delivery)
        end

        it "allows unselecting all delivery schedules" do
          product.delivery_schedules = [monday_delivery, wednesday_delivery]
          expect(product.delivery_schedules.count).to eql(2)

          product.delivery_schedule_ids = []
          product.save

          expect(product.reload.delivery_schedules.count).to eql(0)
        end
      end
    end
  end

  describe ".for_sort" do
    context "by price" do
      let!(:market) { create(:market) }
      let!(:organization) { create(:organization, :seller, markets: [market]) }
      let!(:product_with_prices) { create(:product, :sellable, organization: organization) }
      let!(:product_without_prices) { create(:product, organization: organization) }

      it "sorts products without a price" do
        sorted = organization.products.for_sort("price-asc")
        expect(sorted.to_a).to eql([product_without_prices, product_with_prices])

        sorted = organization.products.for_sort("price-desc")
        expect(sorted.to_a).to eql([product_with_prices, product_without_prices])
      end
    end

    context "by stock" do
      let!(:market)                    { create(:market) }
      let!(:organization)              { create(:organization, :seller, markets: [market]) }
      let!(:product_with_lots)         { create(:product, :sellable, organization: organization) }
      let!(:product_without_lots)      { create(:product, organization: organization) }
      let!(:product_with_expired_lots) { create(:product, organization: organization) }

      it "sorts products with lots" do
        Timecop.travel(6.days.ago) do
          create(:lot, product: product_with_expired_lots, number: "1", expires_at: 1.day.from_now, quantity: 100)
        end

        sorted = organization.products.for_sort("stock-asc")
        expect(sorted.to_a.last).to eql(product_with_lots)

        sorted = organization.products.for_sort("stock-desc")
        expect(sorted.to_a.first).to eql(product_with_lots)
      end
    end
  end

  describe "#disable_advanced_inventory" do
    let!(:plan)    { create(:plan, advanced_inventory: true) }
    let!(:market)  { create(:market, plan: plan) }
    let!(:org)     { create(:organization, :seller, :single_location, markets: [market]) }
    let!(:product) { create(:product, organization: org) }
    let!(:lot1)    { product.lots.create!(quantity: 10, number: "1") }
    let!(:lot2)    { product.lots.create!(quantity: 20, number: "2", expires_at: 2.days.from_now) }
    let!(:lot3)    { product.lots.create!(quantity: 30, number: "3", good_from: 1.day.from_now, expires_at: 2.days.from_now) }

    it "rolls the available inventory into one lot" do
      expect(product.lots.count).to eql(3)
      expect(product.available_inventory).to eql(30)

      product.disable_advanced_inventory(market)

      expect(product.reload.lots.count).to eql(1)
      expect(product.reload.available_inventory).to eql(30)
    end
  end
end
